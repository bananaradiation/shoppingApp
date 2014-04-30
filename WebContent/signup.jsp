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
<script src="//ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"></script>

<title>Shopping App: Sign-up Page</title>
</head>

<body>
<h1>Welcome :) </h1>

	<%  

	ArrayList<String> roles = new ArrayList<String>();
		roles.add("Owner");
		roles.add("Customer");

	String stateList[] = {"Alabama","Alaska","Arizona","Arkansas",
	   "California","Colorado","Connecticut","Delaware","Florida","Georgia",
	   "Hawaii","Idaho","Illinois","Indiana","Iowa","Kansas","Kentucky",
	   "Louisiana","Maine","Maryland","Massachusetts","Michigan","Minnesota",
	   "Mississippi","Missouri","Montana","Nebraska","Nevada","New Hampshire",
	   "New Jersey","New Mexico","New York","North Carolina","North Dakota",
	   "Ohio","Oklahoma","Oregon","Pennsylvania","Rhode Island",
	   "South Carolina","South Dakota","Tennessee","Texas","Utah","Vermont",
	   "Virginia","Washington","West Virginia","Wisconsin","Wyoming"};
		
	ArrayList<String> states = new ArrayList<String>();
	for (int i = 0; i < 50; i++) {
		states.add(stateList[i]);
	}
    %>
    
    
    <!-- Add an HTML table header row to format the results -->
    
    <h2>Sign Up Now!</h2>
		<form action="login.jsp" method="POST">

		Name: <input type="text" name="name" size="20"/><p/>
		Role: <select name="role">
					<option value="owner">Owner</option>
					<option value="customer">Customer</option>
			  </select><p/>
		Age: <input type="text" name="age" size="20"/><p/>
		State: <select name="state">
				<% for (int i = 0; i < 50; i++) { %>
					<option value="<%=stateList[i]%>"><%=stateList[i]%></option>
				<% } %>
			  </select><p/>
		<button type="submit">Sign Up</button>
		</form>

</body>
</html>