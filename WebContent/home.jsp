<%@ include file="/header.jsp" %>

<title>Shopping Home</title>
</head>
<body>

<%
	String name = request.getParameter("name");
	session.setAttribute("name", name);
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
		%>
		Welcome <%= name %> <p/>
		
	 		<%
	 		if (role.equals("owner")) {%>
	 				<a href="/ShoppingApplication/categories.jsp">Go to Categories</a><p/>
	 				<a href="/ShoppingApplication/products.jsp">Go to Products</a><p/>
	 				<input type="hidden" name="action" value="owner"/>
	 				<input type="hidden" name="name" value="<%= name %>"/> <%
				}
	 		else if (role.equals("customer")) {%> 
	 				<a href="/ShoppingApplication/browse.jsp">Go to Product Browsing</a><p/>
	 				<a href="/ShoppingApplication/order.jsp">Go to Order Page</a> <p/>
	 				<input type="hidden" name="action" value="customer"/> <%
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