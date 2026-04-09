// TODO REFATORAR

package negocio;

import java.util.Arrays;

public class Anexo {

    private int id;
    private String descricao;
    private Requerimento requerimento;
    /**
     * Conceito — BYTEA → byte[]:
     * BYTEA no PSQL armazena dados binários brutos → Basicamente qualquer tipo de arquivo
     * Dentro do Java, isso é representado por um Array de Bytes (byte[]).
     * 
     * Pode ser null — A coluna não tem NOT NULL no SQL,
     * ou seja, o anexo pode ter apenas um descrição sem arquivo  
     */
    private byte[] arquivo;

    public int getIdAnexo() {
        return id;
    }

    public String getDescricaoAnexo() {
        return descricao;
    }

    public Requerimento getRequerimentoAnexo() {
        return requerimento;
    }

    public byte[] getArquivoAnexo() {
        if(arquivo == null){
            return null;
        } else {
            arquivo = Arrays.copyOf(arquivo, arquivo.length);
            return arquivo;
        }
    }

    public Anexo(int id, String descricao, byte[] arquivo, Requerimento requerimento){
        setIdAnexo(id);
        setDescricaoAnexo(descricao);
        setArquivoAnexo(arquivo);
        setRequerimentoAnexo(requerimento);
    }

    public void setIdAnexo(int id){
        if(id <= 0){
            System.out.println("Id Inválido");
        } else {
            this.id = id;
        }
    }

    public void setDescricaoAnexo(String descricao){
        if(descricao == null || descricao.trim().isEmpty()){
            System.out.println("Descrição Inválida");
        } else {
            this.descricao = descricao;
        }
    }

    public void setArquivoAnexo(byte[] arquivo){
        if(arquivo == null){
            System.out.println("Anexo Sem Arquivo");
        } else {
            arquivo = Arrays.copyOf(arquivo, arquivo.length);
            this.arquivo = arquivo;
        }
    }

    public void setRequerimentoAnexo(Requerimento requerimento){
        if(requerimento == null){
            System.out.println("Requerimento");
        } else {
            this.requerimento = requerimento;
        }
    }

    public boolean temArquivo(){
        if(arquivo != null){
            return true;
        }
        return false;
    }

    int tamanho;
    public int getTamanhoArquivo(){
        if(temArquivo()){
            tamanho = arquivo.length;
        } else {
            tamanho = 0;
        }
        return tamanho;

    }

    @Override
    public String toString() {
        return "Anexo #"      + id +
               " | Descrição: " + descricao +
               " | Arquivo: "   + (temArquivo() ? getTamanhoArquivo() + " bytes" : "Sem arquivo") +
               " | Requerimento: " + (requerimento != null ? requerimento : "Não vinculado");
    }
}
