<%@page import="geotech.Permissions"%>
<%@page import="geotech.ExtStore"%>
<%@page contentType="application/json" pageEncoding="UTF-8"%>
<%

String sql;

if (!Permissions.canRead(session, "tools_access_demands", response, out)) {
	return;
}

sql = 	"SELECT\n" + 
		"	ad.demand_id AS id,\n" +
		"	ad.status,\n" +
		"	ad.created,\n" +
		"	ad.real_name,\n" +
		"	ad.user_name,\n" +
		"	u.login AS applicant,\n" +
		"	ad.demand_type,\n" +
		"	ad.group1,\n" +
		"	ad.access_level1,\n" +
		"	ad.group2,\n" +
		"	ad.access_level2,\n" +
		"	ad.group3,\n" +
		"	ad.access_level3,\n" +
		"	ad.copy_user_id,\n" +
		"	ad.obs,\n" +
		"	ad.updated,\n" +
		"	ua.login AS approver,\n" +
		"	ad.reason,\n" +
		"	CASE WHEN ad.status = 'Em análise' THEN 1 ELSE 0 END AS demand_order\n" +
		"FROM\n" + 
		"	access_demands ad \n" +
		"	INNER JOIN gt_users u ON u.id = ad.applicant_id \n" +
		"	LEFT JOIN gt_users ua ON ua.id = ad.approver_id \n" +
		"ORDER BY\n" +
		"	demand_order DESC, created DESC";

ExtStore.generateStore(sql, request, out);
%>