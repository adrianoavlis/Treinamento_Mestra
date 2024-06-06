import pandas as pd

def carregar_tabelas(file_path):
    # Carregando o arquivo Excel
    xls = pd.ExcelFile(file_path)
    
    # Supondo que as tabelas estejam em folhas diferentes chamadas 'Identificadores' e 'Qualificadores'
    identificadores_df = pd.read_excel(xls, 'Identificadores')
    qualificadores_df = pd.read_excel(xls, 'Qualificadores')
    
    # Convertendo os dataframes para dicionários com IDIDT e IDQLF como chaves
    identificadores = pd.Series(identificadores_df.DCIDT.values, index=identificadores_df.IDIDT).to_dict()
    qualificadores = pd.Series(qualificadores_df.DCQLF.values, index=qualificadores_df.IDQLF).to_dict()
    
    return identificadores, qualificadores

def buscar_descricao_concatenada(identificadores, qualificadores, ididt, idqlf):
    dcidt = identificadores.get(ididt)
    dcqlf = qualificadores.get(idqlf)
    
    if dcidt and dcqlf:
        return dcidt + " " + dcqlf
    else:
        return "Identificador ou qualificador não encontrado."

def main():
    file_path = input("Digite o caminho do arquivo Excel: ")
    identificadores, qualificadores = carregar_tabelas(file_path)
    
    while True:
        ididt_input = input("Digite o IDIDT (ou 'sair' para terminar): ")
        if ididt_input.lower() == 'sair':
            break
        idqlf_input = input("Digite o IDQLF: ")
        
        descricao_concatenada = buscar_descricao_concatenada(identificadores, qualificadores, ididt_input, idqlf_input)
        print("Descrição concatenada:", descricao_concatenada)

if __name__ == "__main__":
    main()