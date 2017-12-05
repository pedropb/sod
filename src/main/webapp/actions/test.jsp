<%@page pageEncoding="UTF-8" contentType="application/json; charset=UTF-8"%>
<%@page import="alttus.ADAuth"%>
<%
ADAuth auth = ADAuth.createADAuth();
out.println("Expected true, found: " + auth.authenticate("bob.johnson", "Pass@word1!"));
out.println("Expected false, found: " + auth.authenticate("bob.johnson", "asd"));
out.println("Expected true, found: " + auth.authenticate("mary.smith", "Pass@word1!"));
out.println("Expected false, found: " + auth.authenticate("mary.smith", "asd"));
%>
