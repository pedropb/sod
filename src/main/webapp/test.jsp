<%@page import="geotech.KettleJavaClassExecutinJob"%>
<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
KettleJavaClassExecutinJob test = new KettleJavaClassExecutinJob();
test.main(getServletContext());
%>