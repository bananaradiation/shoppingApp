<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Categories</title>
</head>
<body>

<!-- check that name is in database -->

<%
String name = request.getParameter("name");
session.setAttribute("name", name);
%>




<!-- if (valid user) { -->
<%-- 	Hello <%= session.getAttribute("name") %> --%>
<!-- } -->
<!-- else { -->
<%-- 	The provided name <%= session.getAttribute("name") %> is not known. <p/> --%>
<!-- 	<form method="GET" action="categories.jsp"> -->
<!-- 	Name: 	<input type="text" name="name" size="30"/><p/> -->
<!-- 			<input type="submit" value="Log in"/> -->
<!-- 	</form> -->
<!-- } -->


<!-- ?action=owner/customer -->
<!-- 	if (role.equals("owner")) { -->
<!-- 		show categories.jsp -->
<!-- 	} -->
<!-- 	if (role.equals("customer")) { -->
<!-- 		show productBrowse.jsp -->
<!-- 	} -->












</body>
</html>