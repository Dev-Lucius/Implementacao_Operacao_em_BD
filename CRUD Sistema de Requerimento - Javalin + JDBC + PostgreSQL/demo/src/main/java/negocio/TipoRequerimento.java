package negocio;

public class TipoRequerimento {

    // SERIAL PRIMARY KEY → contador estático, gerado automaticamente
    private static int proximoId = 1;
    private final int id;
    // TEXT NOT NULL → obrigatório e imutável
    private final String descricao;

    /**
     * Construtor do TipoRequerimento.
     * O ID é gerado automaticamente.
     *
     * @param descricao Descrição do tipo. Não pode ser nula ou vazia.
     */
    public TipoRequerimento(String descricao) {
        this.id        = proximoId++;
        this.descricao = validarDescricao(descricao);
    }

    // VALIDADOR PRIVADO
    private String validarDescricao(String descricao) {
        if (descricao == null || descricao.trim().isEmpty())
            throw new IllegalArgumentException("Descrição inválida: não pode ser nula ou vazia.");
        return descricao.trim();
    }

    // GETTERS
    public int    getId()        { return id; }
    public String getDescricao() { return descricao; }

    // toString()
    @Override
    public String toString() {
        return "TipoRequerimento #" + id + " | " + descricao;
    }
}
