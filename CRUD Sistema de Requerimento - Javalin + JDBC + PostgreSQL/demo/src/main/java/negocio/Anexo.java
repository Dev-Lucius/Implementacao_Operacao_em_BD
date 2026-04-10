package negocio;

import java.util.Arrays;

public class Anexo {

    private static int proximoId = 1;
    private final int id;
    private final String descricao;
    /**
     * Conceito — BYTEA → byte[]:
     * BYTEA no PSQL armazena dados binários brutos → Basicamente qualquer tipo de arquivo
     * Dentro do Java, isso é representado por um Array de Bytes (byte[]).
     * 
     * Pode ser null — A coluna não tem NOT NULL no SQL,
     * ou seja, o anexo pode ter apenas um descrição sem arquivo  
     */
    private byte[] arquivo;
    private Requerimento requerimento;

    /**
     * @param descricao    Descrição do anexo. Não pode ser nula ou vazia.
     * @param arquivo      Conteúdo binário. Pode ser null.
     * @param requerimento Requerimento vinculado. Pode ser null.
     */
    public Anexo(String descricao, byte[] arquivo, Requerimento requerimento) {
        this.id           = proximoId++;
        this.descricao    = validarDescricao(descricao);
        // Cópia defensiva — protege o estado interno do objeto
        this.arquivo      = arquivo != null ? Arrays.copyOf(arquivo, arquivo.length) : null;
        this.requerimento = requerimento; // null permitido pelo SQL
    }

    // VALIDADOR PRIVADO
    private String validarDescricao(String descricao) {
        if (descricao == null || descricao.trim().isEmpty()){
            throw new IllegalArgumentException("Descrição inválida: não pode ser nula ou vazia.");
        }
        return descricao.trim();
    }

    // GETTERS
    public int          getId()           { return id; }
    public String       getDescricao()    { return descricao; }
    public Requerimento getRequerimento() { return requerimento; }

    /**
     * Retorna uma cópia defensiva do arquivo.
     * CONCEITO —> DEFENSIVE COPY no GETTER:
     * Retornamos uma cópia independente para que o chamador
     * não possa modificar o array interno do objeto.
     *
     * @return cópia do arquivo em bytes, ou null se não houver arquivo.
     */
    public byte[] getArquivo() {
        // BUG CORRIGIDO: retorna a cópia sem modificar this.arquivo
        return arquivo != null ? Arrays.copyOf(arquivo, arquivo.length) : null;
    }

    // SETTERS 
    /**
     * Atualiza o arquivo do anexo.
     *
     * @param arquivo Novo conteúdo binário. Pode ser null para remover o arquivo.
     */
    public void setArquivo(byte[] arquivo) {
        if(arquivo != null){
            arquivo = Arrays.copyOf(arquivo, arquivo.length);
            this.arquivo = arquivo;
        }
        this.arquivo = null;
    }

    /**
     * Vincula um Requerimento a este Anexo.
     *
     * @param requerimento Requerimento a vincular. Pode ser null para desvincular.
     */
    public void setRequerimento(Requerimento requerimento) {
        // null é permitido — anexo pode existir sem requerimento vinculado
        this.requerimento = requerimento;
    }

    // -------------------------------------------------------
    // MÉTODOS UTILITÁRIOS
    // -------------------------------------------------------

    /**
     * Verifica se o anexo possui um arquivo vinculado.
     *
     */
    public boolean temArquivo() {
        if(arquivo != null && arquivo.length > 0){
            return true;
        }
        return false;
    }

    /**
     * Retorna o tamanho do arquivo em bytes.
     *
     * BUG CORRIGIDO: "int tamanho" era um ATRIBUTO da classe
     * em vez de uma variável local. Isso significa que seu valor
     * ficava salvo entre chamadas — comportamento desnecessário
     * e potencialmente confuso. Variáveis de cálculo temporário
     * devem sempre ser locais ao método.
     *
     * @return tamanho em bytes, ou 0 se não houver arquivo.
     */
    public int getTamanhoArquivo() {
        if(temArquivo()){
            return arquivo.length;
        }
        return 0;
    }

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder();

        sb.append("Anexo # ").append(id);
        sb.append("\nDescrição: ").append(descricao);

        sb.append("\nArquivo: ");
        if(temArquivo()){
            sb.append(getTamanhoArquivo()).append("bytes");
        } else {
            sb.append("Sem Arquivo Associado ao Anexo");
        }

        sb.append("\nRequerimento: ");
        if(requerimento != null){
            sb.append("Requerimento # ").append(requerimento.getId());
        }

        return sb.toString();
    }
}
