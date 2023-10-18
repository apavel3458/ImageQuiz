/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package imagequiz;

import org.hibernate.Session;
import org.imagequiz.HibernateUtil;

/**
 *
 * @author apavel
 */
public class IqcaseController {
    private Session session=HibernateUtil.getSessionFactory().getCurrentSession();

}
