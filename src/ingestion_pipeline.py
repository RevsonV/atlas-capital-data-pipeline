import os
import requests
import pandas as pd
import pandas_gbq
import logging

# 1. Configuração de Logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# 2. Constantes do Projeto Atlas Capital
# Os países alvo do fundo
PAISES_ALVO = ["BRA", "IND", "MEX", "IDN", "ZAF", "CHL"]
# Os 5 KPIs definidos
INDICADORES_ATLAS = ["NY.GDP.MKTP.CD", "FP.CPI.TOTL.ZG", "SP.POP.TOTL", "GC.DOD.TOTL.GD.ZS", "SL.UEM.TOTL.ZS"]
# Destino no BigQuery
TABLE_ID = "raw_atlas_capital.stg_indicadores_brutos"
PROJECT_ID = os.getenv("GCP_PROJECT_ID")

# 3. URL Base e Otimização da Chamada
# A API World Bank requer uma chamada separada para cada país-indicador
BASE_API_URL = "https://api.worldbank.org/v2/country/{country}/indicator/{indicator}?format=json&date=2000:2024&per_page=2000"

def extract_world_bank_data(countries, indicators):
    """Extrai dados da World Bank API para múltiplos países e indicadores com resiliência e tratamento de erros."""
    all_data = []
    total_requests = len(countries) * len(indicators)
    request_count = 0
    
    # Itera sobre cada combinação de país e indicador (ação para cada indicador de cada país)
    for country in countries:
        for indicator in indicators:
            request_count += 1
            url = BASE_API_URL.format(country=country, indicator=indicator)
            logging.info(f"[{request_count}/{total_requests}] Extração para país: {country}, indicador: {indicator}")
            
            try:
                response = requests.get(url, timeout=30)  # Definindo timeout para resiliência
                response.raise_for_status()  # Levanta uma exceção para códigos de status ruins (4xx ou 5xx)
                
                dados_principais = response.json()
                
                # A resposta JSON da World Bank API é uma lista de dois elementos
                # O segundo elemento é o array de dados principais. O primeiro é metadata.
                if dados_principais and len(dados_principais) >= 2 and dados_principais[1]:
                    all_data.extend(dados_principais[1])
                    logging.info(f"  ✓ {len(dados_principais[1])} registros obtidos")
                else:
                    logging.warning(f"  ✗ Nenhum dado foi retornado")
                    
            except requests.exceptions.HTTPError as e:
                logging.error(f"  ✗ Erro HTTP. Status: {e.response.status_code}")
            except requests.exceptions.RequestException as e:
                logging.error(f"  ✗ Erro de Conexão: {e}")
    
    logging.info(f"Total de registros extraídos: {len(all_data)}")
    return all_data if all_data else None

def transform_raw_to_dataframe(raw_data):
    """Normaliza o JSON da API para um DataFrame do Pandas."""
    if not raw_data:
        return pd.DataFrame()
        
    # Converte lista de registros em DataFrame
    # A API retorna: country (dict com 'id' e 'value'), indicator (dict), date, value, etc.
    df = pd.DataFrame({
        'country_code': [rec['country'].get('id', '') if isinstance(rec.get('country'), dict) else '' for rec in raw_data],
        'country_name': [rec['country'].get('value', '') if isinstance(rec.get('country'), dict) else '' for rec in raw_data],
        'indicator_code': [rec['indicator'].get('id', '') if isinstance(rec.get('indicator'), dict) else '' for rec in raw_data],
        'indicator_name': [rec['indicator'].get('value', '') if isinstance(rec.get('indicator'), dict) else '' for rec in raw_data],
        'date': [rec.get('date', '') for rec in raw_data],
        'value': [rec.get('value', None) for rec in raw_data]
    })
    
    # Remove linhas com valores nulos
    df = df[df['value'].notna()].copy()
    
    return df

def load_to_bigquery(df, table_id, project_id):
    """Carrega o DataFrame para o BigQuery usando pandas_gbq."""
    if df.empty:
        logging.info("DataFrame vazio. Nenhuma carga de dados necessária.")
        return

    logging.info(f"Iniciando carga de {len(df)} linhas para {table_id}...")
    
    try:
        pandas_gbq.to_gbq(
            df,
            table_id,
            project_id=project_id,
            if_exists='replace',
            progress_bar=False
        )
        logging.info("Carga concluída com sucesso no BigQuery.")
    except Exception as e:
        logging.error(f"Erro ao carregar dados no BigQuery: {e}")


if __name__ == "__main__":
    raw_data = extract_world_bank_data(PAISES_ALVO, INDICADORES_ATLAS)
    df_transformed = transform_raw_to_dataframe(raw_data)
    
    if not df_transformed.empty:
        load_to_bigquery(df_transformed, TABLE_ID, PROJECT_ID)
    else:
        logging.warning("Pipeline concluído, mas sem dados para carregar. Verifique os logs de erro.")
