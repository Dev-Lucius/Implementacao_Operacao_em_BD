package negocio;


public class Aluno {
    private String matricula;
    private Usuario usuario;
    private Curso curso;
    private StatusAluno statusAluno;
    
    public Aluno() {

    }
    public Aluno(String matricula) {
        this.matricula = matricula;
    }
    public String getMatricula() {
        return matricula;
    }
    public void setMatricula(String matricula) {
        this.matricula = matricula;
    }
    public Usuario getUsuario() {
        return usuario;
    }
    public void setUsuario(Usuario usuario) {
        this.usuario = usuario;
    }
    public Curso getCurso() {
        return curso;
    }
    public void setCurso(Curso curso) {
        this.curso = curso;
    }
    public StatusAluno getStatusAluno() {
        return statusAluno;
    }
    public void setStatusAluno(StatusAluno statusAluno) {
        this.statusAluno = statusAluno;
    }
    

}
