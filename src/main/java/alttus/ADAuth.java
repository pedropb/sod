package alttus;

import java.util.*;
 
import javax.naming.*;
import javax.naming.directory.*;
 
public final class ADAuth {
 
    private final String ldapUrl;
    private final String searchBase;
    private final String masterUserDN;
    private final String masterPassword;
 
    public ADAuth(String ldapUrl, String searchBase, String masterUserDN, String masterPassword) {
        this.ldapUrl = ldapUrl;
        this.searchBase = searchBase;
        this.masterUserDN = masterUserDN;
        this.masterPassword = masterPassword;
    }

    public static ADAuth createADAuth() {
        try {
			Context ctx = new InitialContext();
			Context env = (Context) ctx.lookup("java:comp/env");
			final String USER_DN = (String) env.lookup("USER_DN");
            final String AD_PASSWORD = (String) env.lookup("AD_PASSWORD");
            final String LDAP_URL = (String) env.lookup("LDAP_URL");
            final String SEARCH_BASE = (String) env.lookup("SEARCH_BASE");
            
            return new ADAuth(LDAP_URL, SEARCH_BASE, USER_DN, AD_PASSWORD);
		}
		catch (NamingException ex) {
			System.err.println("Could not load environment properties from web.xml.");
			ex.printStackTrace();
			return null;
        }
    
    }
    
    public boolean isValidLogin(String username, String password) throws NamingException {
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
        	// Couldn't find user, so return false.
            return false;
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
        try {
        	ctx = authenticate(userObject, password);
        }
        catch (NamingException ex) {
        	return false;
        }
        
        // if authenticated successfully, then we close and return.
        
        ctx.close();
          	
    	return true;
    }
 
    private DirContext authenticate() throws NamingException {
        return authenticate(null, null);
    }
 
    private DirContext authenticate(String username, String password)
            throws NamingException {
        String initialContextFactory = "com.sun.jndi.ldap.LdapCtxFactory";
        String securityAuthentication = "simple";
 
        Hashtable<String, String> env = new Hashtable<>();
        env.put(Context.INITIAL_CONTEXT_FACTORY, initialContextFactory);
        env.put(Context.SECURITY_AUTHENTICATION, securityAuthentication);
        env.put(Context.PROVIDER_URL, ldapUrl);
        env.put(Context.SECURITY_PRINCIPAL,
                username != null ? username : MASTER_USER_DN);
        env.put(Context.SECURITY_CREDENTIALS,
                password != null ? password : MASTER_PASSWORD);
 
        DirContext ctx = new InitialDirContext(env);
 
        return ctx;
    }
}