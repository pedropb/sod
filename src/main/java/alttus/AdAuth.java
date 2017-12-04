package altus;
 
import java.util.*;
 
import javax.naming.*;
import javax.naming.directory.*;
 
public final class AdAuth {

    public static boolean authenticate(String user, String password) {
        try {
			Context ctx = new InitialContext();
			Context env = (Context) ctx.lookup("java:comp/env");
			final String USER_DN = (String) env.lookup("USER_DN");
            final String AD_PASSWORD = (String) env.lookup("AD_PASSWORD");
            final String LDAP_URL = (String) env.lookup("LDAP_URL");
            
            String initialContextFactory = "com.sun.jndi.ldap.LdapCtxFactory";
            String securityAuthentication = "simple";
     
            Hashtable<String, String> env = new Hashtable<>();
            env.put(Context.INITIAL_CONTEXT_FACTORY, initialContextFactory);
            env.put(Context.SECURITY_AUTHENTICATION, securityAuthentication);
            env.put(Context.PROVIDER_URL, LDAP_URL);
            env.put(Context.SECURITY_PRINCIPAL,
                    username != null ? username : USER_DN);
            env.put(Context.SECURITY_CREDENTIALS,
                    password != null ? password : AD_PASSWORD);
     
            DirContext ctx = new InitialDirContext(env);
		}
		catch (NamingException ex) {
			System.err.println("Could not load environment properties from web.xml.");
			ex.printStackTrace();
			return null;
        }
    }
 
    private List<String> getAllGroups(String username, String password)
            throws NamingException {
        List<String> result = new ArrayList<>();
 
        String attributeToLookup = "memberOf";
 
        /*
         * 1. Authenticate using master user.
         */
        DirContext ctx = authenticate();
 
        /*
         * 2. Searches by "sAMAccountName" to recover the full
         *    DN of the username trying to login.
         */
        SearchControls searchControls = new SearchControls();
        searchControls.setSearchScope(SearchControls.SUBTREE_SCOPE);
        searchControls.setReturningAttributes(
                new String[] {"distinguishedName"});
        NamingEnumeration<SearchResult> searchResults = ctx.search(
                searchBase,
                String.format("(sAMAccountName=%s)", username),
                searchControls);
        if (!searchResults.hasMore()) {
            /*
             * If can't resolve DN, the user doesn't exists.
             */
            throw new NamingException();
        }
        SearchResult searchResult = searchResults.next();
        Attributes attributes = searchResult.getAttributes();
        Attribute attribute = attributes.get("distinguishedName");
        String userObject = (String) attribute.get();
 
        /*
         * 3. Authenticates to LDAP with the user, will throw if
         *    password is wrong.
         */
        ctx.close();
        ctx = authenticate(userObject, password);
 
        /*
         * 4. Fetch all groups of user.
         */
        attributes = ctx.getAttributes(userObject, 
                                       new String[] {attributeToLookup});
 
        NamingEnumeration<? extends Attribute> allAttributes =
                attributes.getAll();
        while (allAttributes.hasMoreElements()) {
            attribute = allAttributes.nextElement();
            int size = attribute.size();
            for (int i = 0; i < size; i++) {
                String attributeValue = (String) attribute.get(i);
                result.add(attributeValue);
            }
        }
 
        ctx.close();
 
        return result;
    }
}