<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<%@ page import="java.util.*"%>
<%@ page import="java.io.*"%>
<%@ page import="java.sql.*" %>
<%@ page import="org.postgresql.*" %>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">



<% String action = request.getParameter("action");

if (action != null && action.equals("login")) { %> 
	<title>Shopping Home</title>
	</head> 
	<body>
	<%
	String sessionName = request.getParameter("name");
	session.setAttribute("sessionName", sessionName); %>
	Welcome <%= session.getAttribute("sessionName")	%> <p/>
<%
}	

