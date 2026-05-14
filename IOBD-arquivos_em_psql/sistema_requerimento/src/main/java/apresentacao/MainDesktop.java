package apresentacao;

import java.sql.SQLException;

import javax.swing.ImageIcon;
import javax.swing.JFrame;
import javax.swing.JLabel;

import persistencia.RequerimentoDAO;

public class MainDesktop {
    public static void main(String[] args) throws SQLException {

         ImageIcon imageIcon = new ImageIcon(new RequerimentoDAO().obter(11).getAnexo());
        JFrame jFrame = new JFrame();
        jFrame.setSize(500, 500);

        //label
        JLabel jLabel = new JLabel();
        jLabel.setIcon(imageIcon);
        jFrame.add(jLabel);
        jFrame.setVisible(true);

        jFrame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        
    }
    
}
