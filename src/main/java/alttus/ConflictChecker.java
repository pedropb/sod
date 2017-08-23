package alttus;

import geotech.Database;

import org.apache.commons.lang.StringUtils;
import org.apache.commons.lang.StringEscapeUtils;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;
import java.util.ArrayList;
import java.util.SortedMap;
import java.util.TreeMap;


public class ConflictChecker {
	
	private static Database db = new Database();


	/*
	 *	conflictsBetweenTransactions:
	 * 	Checks for conflicts between a set of transactions
	 * 	Returns a list of names of the conflicts found.
	 */
	public static List<String> conflictsBetweenTransactions(String transactions) throws SQLException {
		ArrayList<String> conflicts = new ArrayList<String>();

		if (transactions == null) {
			return conflicts;
		}

		String[] transactionIds = transactions.split("@@");
		for (String id : transactionIds) {
			id = StringEscapeUtils.escapeSql(id);
		}
		String tIds = "('" + StringUtils.join(transactionIds, "','") + "')";

		String sql = "select distinct c.name as conflict_name from conflicts c \n" +
			" inner join transactions t1 on c.activity1 = t1.activity_id \n" +
			" inner join transactions t2 on c.activity2 = t2.activity_id \n" +
			" where t1.transaction_id in "+ tIds +" and t2.transaction_id in "+ tIds +" \n" +
			" and t1.transaction_id <> t2.transaction_id";

		ResultSet result = db.query(sql);
		while (result.next()) {
			conflicts.add(result.getString("conflict_name"));
		}

		return conflicts;
	}

	/*
	 *	conflictsBetweenNewTransactionsAndUser:
	 * 	Checks for conflicts between a set of transactions and the transactions
	 * 	already owned by an user.
	 *
	 *	Note: Does not check for conflicts betweeen transactions of the set
	 *	themselves
	 *
	 * 	Returns a list of names of the conflicts found.
	 */
	public static List<String> conflictsBetweenNewTransactionsAndUser(String transactions, String userId) throws SQLException {
		 ArrayList<String> conflicts = new ArrayList<String>();
		 if (transactions == null || userId == null) {
			 return conflicts;
		 }

		 String[] transactionIds = transactions.split("@@");
		 for (String id : transactionIds) {
			 id = StringEscapeUtils.escapeSql(id);
		 }
		 String tIds = "('" + StringUtils.join(transactionIds, "','") + "')";
		 
		 userId = "'" + StringEscapeUtils.escapeSql(userId) + "'";
		 
		 String sql = "";

		 sql = 	"SELECT DISTINCT \n" +
		 				"	c.name AS conflict_name\n" +
						"FROM \n" +
						"	users_activities ua \n" +
						"	INNER JOIN ( \n" +
						"		select * from conflicts except \n" +
						"		select c1.* \n" +
						"		from conflicts c1 \n" +
						"		inner join users_activities ua1 on c1.activity1 = ua1.activity_id \n" +
						"		inner join users_activities ua2 on c1.activity2 = ua2.activity_id \n" +
						"		where ua1.user_id = ua2.user_id and ua1.user_id = "+ userId +" \n" +
						"  ) c ON ua.activity_id = c.activity1 \n" +
						"	INNER JOIN transactions t ON t.activity_id = c.activity2 \n" +
						"WHERE \n" +
						"	ua.user_id = "+ userId +"\n" +
						"	AND t.transaction_id in " + tIds;

			ResultSet result = db.query(sql);
			while (result.next()) {
				conflicts.add(result.getString("conflict_name"));
			}

			return conflicts;
		}

	/*
	 *	conflictsBetweenNewTransactionsAndGroup:
	 * 	Checks for conflicts between a set of transactions and the transactions
	 * 	already owned by an user.
	 *
	 *	Note: Does not check for conflicts betweeen transactions of the set
	 *	themselves
	 *
	 * 	Returns a hash of group/user and the names of the conflicts found for
	 *	that group/user
	 */
	public static SortedMap<String, List<String>> conflictsBetweenNewTransactionsAndGroup (String transactions, String groupId) throws SQLException {
		SortedMap<String, List<String>> conflicts = new TreeMap<String, List<String>>();

		if (transactions == null || groupId == null) {
	 		return conflicts;
		}


		String[] transactionIds = transactions.split("@@");
		for (String id : transactionIds) {
			id = StringEscapeUtils.escapeSql(id);
		}
		String tIds = "('" + StringUtils.join(transactionIds, "','") + "')";
		String gId = "'" + StringEscapeUtils.escapeSql(groupId) + "'";

		String sql = "";

		// Novos conflitos entre as transações do grupo e as novas transações
		sql = 	"SELECT DISTINCT \n" +
						"	c.name AS conflict_name\n" +
						"FROM \n" +
						"	groups_activities ga \n" +
						"	INNER JOIN ( \n" +
						"		select * from conflicts except \n" +
						"		select c1.* \n" +
						"		from conflicts c1 \n" +
						"		inner join groups_activities ga1 on c1.activity1 = ga1.activity_id \n" +
						"		inner join groups_activities ga2 on c1.activity2 = ga2.activity_id \n" +
						"		where ga1.group_id = ga2.group_id and ga1.group_id = "+ gId +" \n" +
						"  ) c ON ga.activity_id = c.activity1 \n" +
						"	INNER JOIN transactions t ON t.activity_id = c.activity2 \n" +
						"WHERE \n" +
						"	ga.group_id = "+ gId +"\n" +
						"	AND t.transaction_id in "+ tIds;

		ResultSet result = db.query(sql);
		ArrayList<String> groupConflicts = new ArrayList<String>();
		while (result.next()) {
			groupConflicts.add(result.getString("conflict_name"));
		}
		if (!groupConflicts.isEmpty()) {
			conflicts.put("grupo " + groupId, groupConflicts);
		}

		// Novos conflitos entre os usuários do grupo e as novas transações
		sql = 	"SELECT DISTINCT \n" +
						" 	ug.user_id AS user_id, \n" +
						"	c.name AS conflict_name\n" +
						"FROM \n" +
						"	users_groups ug \n" +
						"	INNER JOIN users_activities ua ON ug.user_id = ua.user_id \n" +
						"	INNER JOIN conflicts c ON ua.activity_id = c.activity1 \n" +
						"	INNER JOIN transactions t ON t.activity_id = c.activity2 \n" +
						"WHERE \n" +
						"	ug.group_id = "+ gId +"\n" +
						"	AND t.transaction_id in "+ tIds +" \n" +
						"EXCEPT \n" +
						"SELECT DISTINCT \n" +
						" 	ug.user_id AS user_id, \n" +
						"	c.name AS conflict_name\n" +
						"FROM \n" +
						"	users_groups ug \n" +
						"	INNER JOIN users_activities ua1 ON ug.user_id = ua1.user_id \n" +
						"	INNER JOIN users_activities ua2 ON ug.user_id = ua2.user_id \n" +
						"	INNER JOIN conflicts c ON ua1.activity_id = c.activity1 AND ua2.activity_id = c.activity2 \n" +
						"WHERE \n" +
						"	ug.group_id = "+ gId;

		result = db.query(sql);
		while (result.next()) {
			String userId = "usuário " + result.getString("user_id");
			String conflictName = result.getString("conflict_name");

			List<String> userConflicts = conflicts.get(userId);
			if (userConflicts == null) {
				userConflicts = new ArrayList<String>();
			}

			userConflicts.add(conflictName);
			conflicts.put(userId, userConflicts);
		}
		
		return conflicts;
	}

	/*
	 *	conflictsBetweenNewUsersAndGroup:
	 * 	Checks for conflicts between a set of users and the transactions
	 * 	already owned by a group.
	 *
	 *	Note: Does not check for conflicts betweeen transactions of the set
	 *	themselves
	 *
 	 * 	Returns a hash of user and the names of the conflicts found for that user
	 */
	public static SortedMap<String, List<String>> conflictsBetweenNewUsersAndGroup (String users, String groupId) throws SQLException {
		SortedMap<String, List<String>> conflicts = new TreeMap<String, List<String>>();

		if (users == null || groupId == null) {
	 		return conflicts;
		}


		String gId = "'" + StringEscapeUtils.escapeSql(groupId) + "'";
		String sql = "";
		
		String[] userIds = users.split("@@");
		
		for (String uId : userIds) {
			uId = "'" + StringEscapeUtils.escapeSql(uId) + "'";
			
			sql = 	"SELECT DISTINCT \n" +
					"	c.name AS conflict_name,\n" +
					"	ua.user_id AS user_id\n" +
					"FROM \n" +
					"	groups_activities ga \n" +
					"	INNER JOIN ( \n" +
					"		select * from conflicts except \n" +
					"		select c1.* \n" +
					"		from conflicts c1 \n" +
					"		inner join users_activities ua1 on c1.activity1 = ua1.activity_id \n" +
					"		inner join users_activities ua2 on c1.activity2 = ua2.activity_id \n" +
					"		where ua1.user_id = ua2.user_id and ua1.user_id = "+ uId +" \n" +
					"  ) c ON ga.activity_id = c.activity1 \n" +
					"	INNER JOIN users_activities ua ON ua.activity_id = c.activity2 \n" +
					"WHERE \n" +
					"	ga.group_id = "+ gId +"\n" +
					"	AND ua.user_id = "+ uId;

			ResultSet result = db.query(sql);
			while (result.next()) {
				String userId = "usuário " + result.getString("user_id");
				String conflictName = result.getString("conflict_name");

				List<String> userConflicts = conflicts.get(userId);
				if (userConflicts == null) {
					userConflicts = new ArrayList<String>();
				}

				userConflicts.add(conflictName);
				conflicts.put(userId, userConflicts);
			}
		}
		

		
		
		return conflicts;
	}
}
