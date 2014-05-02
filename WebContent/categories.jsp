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

<title>Categories</title>
</head>

<body>

<%

// Get parameters from home.jsp or categories.jsp
String action = request.getParameter("action");
String name = (String)session.getAttribute("sessionName");

Connection conn = null;
PreparedStatement pstmt = null;
ResultSet rs = null;
String selectSQL;
Statement st = null;

try {
    // Registering Postgresql JDBC driver with the DriverManager
    Class.forName("org.postgresql.Driver");

    // Open a connection to the database using DriverManager
    conn = DriverManager.getConnection(
        "jdbc:postgresql://localhost/cse135?" +
        "user=postgres&password=postgres");
    
	int ownerID = Integer.parseInt((String)session.getAttribute("sessionID"));
	
	if (action != null && action.equals("insert")) {
		String categoryName = request.getParameter("categoryName");
		String description = request.getParameter("description");

		// Start transaction
	    conn.setAutoCommit(false);

	    pstmt = conn
	    .prepareStatement("INSERT INTO categories (name, description, owner) VALUES (?, ?, ?)");
	    
	    pstmt.setString(1, categoryName);
	    pstmt.setString(2, description);
	    pstmt.setInt(3, ownerID);
	    int rowCount = pstmt.executeUpdate();

	    if (rowCount > 0) { 
		    conn.commit();
		    conn.setAutoCommit(true);
		    // End Transaction
	    }
	}

	if (action != null && action.equals("update")) {
		String categoryName = request.getParameter("categoryName");
		String description = request.getParameter("description");
		int categoryID = Integer.parseInt(request.getParameter("categoryID"));

		// Start Transaction
		conn.setAutoCommit(false);
	    
	    pstmt = conn.prepareStatement("UPDATE categories SET name = ?, description = ?  WHERE ID = ?");
	    pstmt.setString(1, categoryName);
	    pstmt.setString(2, description);
	    pstmt.setInt(3, categoryID);
	    int rowCount = pstmt.executeUpdate();

	    if (rowCount > 0) {
		    conn.commit();
		    conn.setAutoCommit(true);
		    // End Transaction
	    }
	}	

	if (action != null && action.equals("delete")) {
		int categoryID = Integer.parseInt(request.getParameter("categoryID"));
        // Start transaction
        conn.setAutoCommit(false);

        pstmt = conn.prepareStatement("DELETE FROM categories WHERE ID = ?");
        pstmt.setInt(1, categoryID);
        int rowCount = pstmt.executeUpdate();

        if (rowCount > 0) {
	        conn.commit();
	        conn.setAutoCommit(true);
			// End transaction
        }
	}
	
	// populate table with database categories
	Statement statement = conn.createStatement();
	rs = statement.executeQuery("SELECT name, description, ID FROM categories"); %>
	
	Hello <%= name %> <p/>
	<a href="products.jsp?category=all">Click to go to Products</a></p>

	<div class="content">
	<table>
		<tr>
			<th>Category Name</th>
		    <th>Description</th>
		</tr>
		<tr>
			<form action="categories.jsp" method="POST">
		        <input type="hidden" name="action" value="insert"/>
				<td><input type="text" value="" name="categoryName" size="15"/></td>
		        <td><input type="text" name="description" size="40"/></td>
		        <td><input type="submit" value="Insert"/></td>
	        </form>
		</tr> 
	<%
	while (rs.next()) {
		// check if category name has products associated with it
    	Boolean deleteOK = false;
		pstmt = conn.prepareStatement("SELECT ID FROM products WHERE products.category = ?");
  		pstmt.setInt(1, rs.getInt("ID"));
  		ResultSet rs2 = pstmt.executeQuery();
  		if (!rs2.next()) {
  			deleteOK = true;
  		}
		%>
		<tr>
			<form action="categories.jsp" method="POST"> 		
		   		<td><input value="<%=rs.getString("name")%>" name="categoryName" size="15"/></td>
		    	<td><input value="<%=rs.getString("description")%>" name="description" size="40"/></td>
		    	<input type="hidden" name="action" value="update"/>
	        	<input type="hidden" name="categoryID" value="<%= rs.getInt("ID")%>"/>
			    <td><input type="submit" value="Update"></td>
    		</form> 
    		<%
    		if (deleteOK) { %>
         		<form action="categories.jsp" method="POST">
		 	        <input type="hidden" name="action" value="delete"/>
		 	        <input type="hidden" name="categoryID" value="<%= rs.getInt("ID") %>"/>
			    	<td><input type="submit" value="Delete"/></td>
    			</form> <%
			} %>
		</tr> <%
	} %>	
	</table>
	</div> <%
	

	rs.close();
	statement.close();
	conn.close();
}
catch (SQLException e) {
	%>
	Requested data modification failed. <p/>
	<a href="/categories.jsp">Click here to go back to Categories</a>
    <% 
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