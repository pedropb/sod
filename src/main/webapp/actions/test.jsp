<%@page pageEncoding="UTF-8" contentType="text/plain; charset=UTF-8"%>
<%@page import="alttus.ADAuth"%>
<%
ADAuth auth = ADAuth.createADAuth();
out.println("Expected true, found: " + auth.isValidLogin("bob.johnson", "Pass@word1!"));
out.println("Expected false, found: " + auth.isValidLogin("bob.johnson", "asd"));
out.println("Expected true, found: " + auth.isValidLogin("mary.smith", "Pass@word1!"));
out.println("Expected false, found: " + auth.isValidLogin("mary.smith", "asd"));
%>
