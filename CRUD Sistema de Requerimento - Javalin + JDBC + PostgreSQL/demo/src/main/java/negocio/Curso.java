package negocio;

/**
 * Mapeamento da tabela SQL:
 * CREATE TABLE curso(
 *     id SERIAL PRIMARY KEY,
 *     nome VARCHAR(200) NOT NULL,
 *     site VARCHAR(200) NOT NULL,
 *     turno VARCHAR(20) CHECK (turno IN ('noturno', 'diurno', 'vespertino')),
 *     duracao INTEGER CHECK (duracao > 0)
 * );
 *
 * CONCEITO — CLASSE SEM DEPENDÊNCIAS:
 * Curso não referencia nenhuma outra tabela — é o ponto
 * de partida da hierarquia. Por isso é implementada primeiro.
 */
public class Curso {

    // SERIAL PRIMARY KEY → contador estático
    private static int proximoId = 1;
    private final int id;

    // VARCHAR(200) NOT NULL → String obrigatória
    private final String nome;
    private final String site;

    /**
     * CHECK (turno IN ('noturno', 'diurno', 'vespertino'))
     *
     * CONCEITO — ENUM:
     * O CHECK do SQL que restringe os valores possíveis
     * é modelado em Java como um enum — a forma mais segura
     * de representar um conjunto fixo de opções.
     * Impossível criar um Turno inválido em tempo de compilação.
     */
    public enum Turno {
        NOTURNO, DIURNO, VESPERTINO
    }

    private final Turno turno;

    // INTEGER CHECK (duracao > 0) → int com validação
    private final int duracao; // em horas

    public Curso(String nome, String site, Turno turno, int duracao) {
        this.id      = proximoId++;
        this.nome    = validarTexto(nome, "Nome");
        this.site    = validarTexto(site, "Site");

        if (turno == null)
            throw new IllegalArgumentException("Turno inválido.");
        this.turno = turno;

        // CHECK (duracao > 0)
        if (duracao <= 0)
            throw new IllegalArgumentException("Duração inválida: deve ser maior que zero.");
        this.duracao = duracao;
    }

    private String validarTexto(String valor, String campo) {
        if (valor == null || valor.trim().isEmpty())
            throw new IllegalArgumentException(campo + " inválido: não pode ser nulo ou vazio.");
        return valor.trim();
    }

    // GETTERS DOS ATRIBUTOS
    public int    getId()      { return id; }
    public String getNome()    { return nome; }
    public String getSite()    { return site; }
    public Turno  getTurno()   { return turno; }
    public int    getDuracao() { return duracao; }

    @Override
    public String toString() {
        return "Curso #" + id +
               " | Nome: "    + nome +
               " | Turno: "   + turno.toString().toLowerCase() +
               " | Duração: " + duracao + "h";
    }
}
