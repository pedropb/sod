<%@page import="geotech.Permissions"%>
<%@page contentType="application/json" pageEncoding="UTF-8"%>
<%@page import="org.json.JSONWriter"%>
<% 
JSONWriter output = new JSONWriter(out);

output.object();
output.key("panelMenu").array();

if (Permissions.canRead(session, "config_usuarios")) {
	output.object();
	output.key("text").value("Usuários");
	output.key("formId").value("listaUsuarios");
	output.endObject();
}

if (Permissions.canRead(session, "config_grupos_permissoes")) {
	output.object();
	output.key("text").value("Grupos");
	output.key("formId").value("listaGruposPermissoes");
	output.endObject();
}

if (Permissions.canRead(session, "config_lembretes")) {
	output.object();
	output.key("text").value("Lembretes");
	output.key("formId").value("listaLembretes");
	output.endObject();
}

output.object();
output.key("text").value("Alterar Senha");
output.key("formId").value("panelAlterarSenha");
output.endObject();

output.endArray();
output.endObject();

%>