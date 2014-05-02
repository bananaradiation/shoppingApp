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
	String sessionID;
	
	if (action != null && action.equals("login")) { %> 
		<title>Shopping Home</title>
		</head> 
		<body>
		<%
		String sessionName = request.getParameter("name");
		session.setAttribute("sessionName", sessionName); 
		%>
	<%
	}	
	String name = request.getParameter("name");	
	String role; 

	Connection conn = null;
	PreparedStatement pstmt = null;
	ResultSet rs = null;

	try {
	    // Registering Postgresql JDBC driver with the DriverManager
	    Class.forName("org.postgresql.Driver");
	
	    // Open a connection to the database using DriverManager
	    conn = DriverManager.getConnection(
	        "jdbc:postgresql://localhost/cse135?" +
	        "user=postgres&password=postgres");
	
	        // Begin transaction
	        conn.setAutoCommit(false);
	
	    // Create the statement
	    Statement statement = conn.createStatement();
	
	    // Use the created statement to SELECT the user's role
	    pstmt = conn.prepareStatement("SELECT * FROM users WHERE name = ?");
	    pstmt.setString(1, name);
		
	    rs = pstmt.executeQuery();	
	    
	    Boolean flag = rs.next();
	    if (flag == false) {
	    	%>The provided name <%= name %> not known <p/>
	    	Please log in below <p/>
            	<form action="home.jsp" method="GET">
					Name: <input type="text" name="name" size="20"/><p/>
					<button type="submit">Log In</button>
				</form>
			<%
	    }
	    else {	    
	    	role = rs.getString("role");
	    	sessionID = rs.getString("ID");
	    	session.setAttribute("sessionID", sessionID);
		%>
		Welcome <%= session.getAttribute("sessionName")	%> <p/>
	 		<%
	 		if (role.equals("owner")) {%>
	 				<a href="/ShoppingApplication/categories.jsp">Go to Categories</a><p/>
	 				<a href="/ShoppingApplication/products.jsp?category=all">Go to Products</a><p/> <%
// 	 				<input type="hidden" name="role" value="owner"/>
				}
	 		else if (role.equals("customer")) {
	 		%> 
	 				<a href="/ShoppingApplication/browse.jsp">Go to Product Browsing</a><p/>
	 				<a href="/ShoppingApplication/order.jsp">Go to Order Page</a> <p/>
	 				<a href="/ShoppingApplication/buyCart.jsp">Buy Shopping Cart</a> <p/>
<!-- 	 				<input type="hidden" name="role" value="customer"/>  -->
	 				<%
	 			} 
	 		else {%>
	 				<input type="hidden" name="action" value=""/><%
	 		}		
	    }
 		// Close the ResultSet
 	    rs.close();
 	    // Close the Statement
 	    statement.close();
 	    // Close the Connection
 	    conn.close();
		
   	} 
	catch (SQLException e) {
    	e.printStackTrace();
	}
	finally {
	    if (rs != null) {
	        try {
	            rs.close();
	        } catch (SQLException e) { } // Ignore
	        rs = null;
	    }
	    if (pstmt != null) {
	        try {
	            pstmt.close();
	        } catch (SQLException e) { } // Ignore
	        pstmt = null;
	    }
	    if (conn != null) {
	        try {
	            conn.close();
	        } catch (SQLException e) { } // Ignore
	        conn = null;
	    }
	}
	%>

</body>
</html>