package negocio;

public final class Curso {
    private int id;
    private String nome;
    private String site;
    private String turno;
    private String duracao;

    public int getIdCurso() {
        return id;
    }

    public String getNomeCurso() {
        return nome;
    }

    public String getSiteCurso() {
        return site;
    }

    public String getTurnoCurso() {
        return turno;
    }

    public String getDuracaoCurso() {
        return duracao;
    }

    public Curso(){
        setIdCurso(id);
        setNomeCurso(nome);
        setSiteCurso(site);
        setTurnoCurso(turno);
        setDuracaoCurso(duracao);
    }

    public void setIdCurso(int id){
        if(id <= 0){
            System.out.println("ID inválido");
        } else {
            this.id = id;
        }
    }

    public void setNomeCurso(String nome){
        if(nome == null || nome.trim().isEmpty()){
            System.out.println("Nome Inválido");
        } else {
            this.nome = nome;
        }
    }

    public void setSiteCurso(String site){
        if(site == null || site.trim().isEmpty()){
            System.out.println("site Inválido");
        } else {
            this.site = site;
        }
    }

    public void setTurnoCurso(String turno){
        if(turno == null || turno.trim().isEmpty()){
            System.out.println("turno Inválido");
        } else {
            this.turno = turno;
        }
    }

    public void setDuracaoCurso(String duracao){
        if(duracao == null || duracao.trim().isEmpty()){
            System.out.println("duracao Inválido");
        } else {
            this.duracao = duracao;
        }
    }
}
