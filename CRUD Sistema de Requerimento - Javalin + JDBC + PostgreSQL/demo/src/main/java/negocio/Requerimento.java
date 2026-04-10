package negocio;

import java.time.LocalDateTime;

public class Requerimento {

    private static int proximoId = 1;
    private final int id;
    // REFERENCES aluno → objeto completo, imutável
    private final Aluno aluno;

    /**
     * TIMESTAMP DEFAULT CURRENT_TIMESTAMP:
     * Capturado automaticamente no construtor com LocalDateTime.now().
     * Imutável — a data de abertura nunca muda após a criação.
     */
    private final LocalDateTime dataHoraAbertura;

    /**
     * CHECK (status IN ('em análise', 'indeferido', 'deferido'))
     * DEFAULT 'em análise'
     *
     * O CHECK do SQL que restringe os valores possíveis é modelado
     * como enum em Java. Impossível atribuir um status inválido
     * em tempo de compilação — muito mais seguro que uma String livre.
     */
    public enum Status {
        EM_ANALISE("em análise"),
        DEFERIDO("deferido"),
        INDEFERIDO("indeferido");

        private final String descricao;

        Status(String descricao) {
            this.descricao = descricao;
        }

        public String getDescricao() {
            return descricao;
        }
    }

    private Status status;
    private final TipoRequerimento tipoRequerimento;

    // CONSTRUTOR
    /**
     * Construtor do Requerimento.
     * Data, ID e status são definidos automaticamente.
     *
     * @param aluno            Aluno que abriu o requerimento. Não pode ser nulo.
     * @param tipoRequerimento Tipo do requerimento. Não pode ser nulo.
     */
    public Requerimento(Aluno aluno, TipoRequerimento tipoRequerimento) {
        this.id               = proximoId++;

        if (aluno == null){
            throw new IllegalArgumentException("Aluno inválido: não pode ser nulo.");
        }
        this.aluno = aluno;

        // DEFAULT CURRENT_TIMESTAMP → capturado automaticamente
        this.dataHoraAbertura = LocalDateTime.now();

        // DEFAULT 'em análise' → estado inicial sempre EM_ANALISE
        this.status           = Status.EM_ANALISE;

        if (tipoRequerimento == null){
            throw new IllegalArgumentException("Tipo de requerimento inválido: não pode ser nulo.");
        }
        this.tipoRequerimento = tipoRequerimento;
    }

    // GETTERS
    public int              getId()               { return id; }
    public Aluno            getAluno()            { return aluno; }
    public LocalDateTime    getDataHoraAbertura() { return dataHoraAbertura; }
    public Status           getStatus()           { return status; }
    public TipoRequerimento getTipoRequerimento() { return tipoRequerimento; }

    // -------------------------------------------------------
    // SETTER DE STATUS
    //
    // CONCEITO — TRANSIÇÃO DE ESTADO CONTROLADA:
    // Um requerimento já finalizado (DEFERIDO ou INDEFERIDO)
    // não pode ter seu status revertido — isso reflete a
    // regra de negócio real de um sistema de requerimentos.
    // -------------------------------------------------------

    /**
     * Atualiza o status do requerimento.
     * @param novoStatus Novo status. Não pode ser nulo.
     * @throws IllegalStateException se o requerimento já estiver finalizado.
     */
    public void setStatus(Status novoStatus) {
        if (novoStatus == null)
            throw new IllegalArgumentException("Status inválido: não pode ser nulo.");

        // Impede reverter um requerimento já finalizado
        if (this.status == Status.DEFERIDO || this.status == Status.INDEFERIDO)
            throw new IllegalStateException(
                "Não é possível alterar o status: requerimento já finalizado como " +
                this.status.getDescricao() + "."
            );

        this.status = novoStatus;
    }


    // toString()
    @Override
    public String toString() {
        return "Requerimento #"    + id +
               " | Aluno: "        + aluno.getNomeAluno() +  // navega: req → aluno → usuario → nome
               " | Tipo: "         + tipoRequerimento.getDescricao() +
               " | Status: "       + status.getDescricao() +
               " | Aberto em: "    + dataHoraAbertura;
    }
}
