package negocio;

import java.time.LocalDate;
import java.time.Period;

public final class Usuario {

    private static int proximoId = 1;
    private final int id;

    private final String nome;   // NOT NULL → final
    private String email;
    private String cpf;
    private LocalDate dataNascimento;

    // Campos de endereço — opcionais (sem NOT NULL)
    private String endereco;
    private String cep;
    private String complemento;
    private String numero;

    // Construtor do Método
    /**
     * @param nome           Nome completo. Obrigatório.
     * @param email          Email válido. Obrigatório.
     * @param cpf            CPF com 11 dígitos. Obrigatório.
     * @param dataNascimento Data de nascimento. Não pode ser futura.
     * @param endereco       Logradouro. Opcional.
     * @param cep            CEP com 8 dígitos. Opcional.
     * @param complemento    Complemento. Opcional.
     * @param numero         Número do endereço. Opcional.
     */
    public Usuario(String nome, String email, String cpf, LocalDate dataNascimento,
                   String endereco, String cep, String complemento, String numero) {
        this.id             = proximoId++;
        this.nome           = validarObrigatorio(nome, "Nome");
        this.email          = validarEmail(email);
        this.cpf            = validarCpf(cpf);
        this.dataNascimento = validarDataNascimento(dataNascimento); // BUG CORRIGIDO
        this.endereco       = endereco;
        this.cep            = validarCep(cep);
        this.complemento    = complemento;
        this.numero         = numero;
    }

    // MÉTODO DE VALIDAÇÃO
    public String validarObrigatorio(String valor, String campo) {
        if (valor == null || valor.trim().isEmpty())
            throw new IllegalArgumentException(campo + " inválido: não pode ser nulo ou vazio.");
        return valor.trim();
    }


    public String validarEmail(String email) {
        if (email == null || email.trim().isEmpty())
            throw new IllegalArgumentException("Email inválido: não pode ser nulo ou vazio.");
        String e = email.trim().toLowerCase();
        int arroba = e.indexOf("@");
        if (arroba < 1 || !e.substring(arroba).contains("."))
            throw new IllegalArgumentException("Email inválido: formato incorreto.");
        return email;
    }


    public String validarCpf(String cpf) {
        if (cpf == null || cpf.trim().isEmpty())
            throw new IllegalArgumentException("CPF inválido: não pode ser nulo ou vazio.");
        // replaceAll --> substitui todas as ocorrências de um padrão específico, definido por uma Expressão Regular (regex), 
        // por uma nova string, retornando uma nova string modificada
        // String.replaceAll(regex, substituição);
        // 0-9 → números de 0 até 9
        // ^ → negação
        // [^0-9] = qualquer coisa que NÃO seja número
        String digitos = cpf.replaceAll("[^0-9]", "");
        if (digitos.length() != 11)
            throw new IllegalArgumentException("CPF inválido: deve conter 11 dígitos.");
        return digitos;
    }

    public LocalDate validarDataNascimento(LocalDate data) {
        if (data == null)
            throw new IllegalArgumentException("Data de nascimento não pode ser nula.");
        if (data.isAfter(LocalDate.now()))
            throw new IllegalArgumentException("Data de nascimento não pode ser no futuro.");
        return data;
    }

    public String validarCep(String cep) {
        if (cep == null) return null;
        String digitos = cep.replaceAll("[^0-9]", "");
        if (digitos.length() != 8)
            throw new IllegalArgumentException("CEP inválido: deve conter 8 dígitos.");
        return digitos;
    }

    // GETTERS
    public int       getId()             { return id; }
    public String    getNome()           { return nome; }
    public String    getEmail()          { return email; }
    public String    getCpf()            { return cpf; }
    public LocalDate getDataNascimento() { return dataNascimento; }
    public String    getEndereco()       { return endereco; }
    public String    getCep()            { return cep; }
    public String    getComplemento()    { return complemento; }
    public String    getNumero()         { return numero; }

    /**
     * Calcula a idade dinamicamente com Period.
     * Period.between() computa a diferença exata entre duas datas.
     */
    public int getIdade() {
        if (dataNascimento == null){ 
            System.out.println("Idade Desconhecida ou Não Informada"); 
            return 0;
        }
        // Cálcula a Idade Real
        // LocalDate.now() --> Retorna a Data Atual do Sistema
        // Period.between() --> calcula a Diferença Entre duas Datas
        // Nesse caso --> LocalDate.now() - dataNascimento
        // getYears() --> Retorna a diferença calculada em Anos !!!
        return Period.between(dataNascimento, LocalDate.now()).getYears();
    }

    // SETTERS
    public void setEmail(String email)             { this.email = validarEmail(email); }
    public void setCpf(String cpf)                 { this.cpf = validarCpf(cpf); }
    public void setDataNascimento(LocalDate data)  { this.dataNascimento = validarDataNascimento(data); }
    public void setEndereco(String endereco)       { this.endereco = endereco; }
    public void setCep(String cep)                 { this.cep = validarCep(cep); }
    public void setComplemento(String complemento) { this.complemento = complemento; }
    public void setNumero(String numero)           { this.numero = numero; }

    // -------------------------------------------------------
    // MÉTODOS DE EXIBIÇÃO
    // -------------------------------------------------------

    /** Exibe apenas os dados de endereço. Mantido da classe original. */
    public String toStringEndereco() {
        return """
               === Endereco Completo ===
               Logradouro: """  + (endereco    != null ? endereco    : "não informado") +
               "\nNúmero: "      + (numero      != null ? numero      : "não informado") +
               "\nComplemento: " + (complemento != null ? complemento : "não informado") +
               "\nCEP: "         + (cep         != null ? cep         : "não informado");
    }

    @Override
    public String toString() {
        return "Usuario #" + id +
               " | Nome: "  + nome +
               " | Email: " + email +
               " | Idade: " + getIdade() + " anos";
    }

    public void setId(int int1) {
        // TODO Auto-generated method stub
        throw new UnsupportedOperationException("Unimplemented method 'setId'");
    }
}
