package negocio;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Base64;

public class Requerimento {
    private int id;
    private LocalDateTime dataHoraAbertura;
    private LocalDateTime dataHoraEncerramento;
    private String observacao;
    private Status status;
    private byte[] anexo;
    private Aluno aluno;
    private TipoRequerimento tipoRequerimento;

    public int getId() {
        return id;
    }

    public TipoRequerimento getTipoRequerimento() {
        return tipoRequerimento;
    }

    public void setTipoRequerimento(TipoRequerimento tipoRequerimento) {
        this.tipoRequerimento = tipoRequerimento;
    }

    public void setId(int id) {
        this.id = id;
    }

    public LocalDateTime getDataHoraAbertura() {
        return dataHoraAbertura;
    }

    public void setDataHoraAbertura(LocalDateTime dataHoraAbertura) {
        this.dataHoraAbertura = dataHoraAbertura;
    }

    public LocalDateTime getDataHoraEncerramento() {
        return dataHoraEncerramento;
    }

    public void setDataHoraEncerramento(LocalDateTime dataHoraEncerramento) {
        this.dataHoraEncerramento = dataHoraEncerramento;
    }

    public String getObservacao() {
        return observacao;
    }

    public void setObservacao(String observacao) {
        this.observacao = observacao;
    }

    public Status getStatus() {
        return status;
    }

    public void setStatus(Status status) {
        this.status = status;
    }

    public byte[] getAnexo() {
        return anexo;
    }

    public void setAnexo(byte[] anexo) {
        this.anexo = anexo;
    }

    public Aluno getAluno() {
        return aluno;
    }

    public void setAluno(Aluno aluno) {
        this.aluno = aluno;
    }

    public String anexoEncode() {

        return Base64.getEncoder().encodeToString(this.anexo);
    }

    public String dataHoraAberturaFormatada() {
        return this.formataLocalDateTime(dataHoraAbertura);
    }

    public String dataHoraEncerramentoFormatada() {

        return this.formataLocalDateTime(dataHoraEncerramento);
    }

    private String formataLocalDateTime(LocalDateTime localDateTime) {
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss");
        // Aplica a formatação
        String dataFormatada = "";
        if (localDateTime != null) {
            dataFormatada = localDateTime.format(formatter);
        }
        return dataFormatada;

    }

}
