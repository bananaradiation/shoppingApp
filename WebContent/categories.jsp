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
String name = (String)session.getAttribute("name");
String categoryName = request.getParameter("categoryName");
String description = request.getParameter("description");
int categoryID = Integer.parseInt(request.getParameter("categoryID"));
            
Connection conn = null;
PreparedStatement pstmt = null;
ResultSet rs = null;
String selectSQL;
Statement st;
        
try {
    // Registering Postgresql JDBC driver with the DriverManager
    Class.forName("org.postgresql.Driver");

    // Open a connection to the database using DriverManager
    conn = DriverManager.getConnection(
        "jdbc:postgresql://localhost/cse135?" +
        "user=postgres&password=postgres");
    
    // Get owner ID from psql
    selectSQL = "SELECT users.ID FROM users WHERE users.name = ?";
	pstmt = conn.prepareStatement(selectSQL);
	pstmt.setString(1, name);
	rs = pstmt.executeQuery(selectSQL);
	rs.next();
	int ownerID = rs.getInt("ID");
	
	// INSERT CODE
	if (action != null && action.equals("insert")) {

	    // Begin transaction
	    conn.setAutoCommit(false);

	    pstmt = conn
	    .prepareStatement("INSERT INTO categories (name, description, owner) VALUES (?, ?, ?)");
	    
	    pstmt.setString(1, categoryName);
	    pstmt.setString(2, description);
	    pstmt.setInt(3, ownerID);
	    int rowCount = pstmt.executeUpdate();

	    if (rowCount > 0) {    
		    // Commit transaction
		    conn.commit();
		    conn.setAutoCommit(true);
	    }
	}
	                        
	// get category ID for update/delete
	selectSQL = "SELECT ID FROM categories WHERE name = ?";
	pstmt = conn.prepareStatement(selectSQL);
	pstmt.setString(1, name);
	rs = pstmt.executeQuery(selectSQL);
	rs.next();
	int categoryID = rs.getInt("ID");
	        
	// UPDATE CODE
	if (action != null && action.equals("update")) {

	    // Begin transaction
	    conn.setAutoCommit(false);
	    
	    pstmt = conn.prepareStatement("UPDATE categories SET name = ?, description = ?  WHERE ID = ?");
	    pstmt.setString(1, categoryName);
	    pstmt.setString(2, description);
	    pstmt.setInt(3, categoryID);
	    int rowCount = pstmt.executeUpdate();

	    if (rowCount > 0) {
	    // Commit transaction
	    conn.commit();
	    conn.setAutoCommit(true);
	    }
	}
	        
	//DELETE Code   
	if (action != null && action.equals("delete")) {

	        // Begin transaction
	        conn.setAutoCommit(false);

	        pstmt = conn.prepareStatement("DELETE FROM categories WHERE ID = ?");
	        pstmt.setInt(1, categoryID);
	        int rowCount = pstmt.executeUpdate();

	        if (rowCount > 0) {
	        // Commit transaction
	        conn.commit();
	        conn.setAutoCommit(true);
	        }
	}
	
	rs.close();
	st.close();
	conn.close();
} 
catch (SQLException e) {
    e.printStackTrace();
}
finally {
    // Release resources in a finally block in reverse-order of
    // their creation

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
	
Hello <%= name %>

<table>
	<tr>
		<th>Category Name</th>
	    <th>Description</th>
	</tr>
<!--first line of table for inserting new categories -->
	
<%
// SELECT statement to generate categories table
st = conn.createStatement();
rs = st.executeQuery("SELECT name, description FROM categories");
%>	
	<tr>
		<form action="categories.jsp" method="POST">
	        <input type="hidden" name="action" value="insert"/>
			<td><input type="text" value="" name="categoryName" size="15"/></td>
	        <td><textarea name="description" cols="30" rows="5"/></td>
	        <td><input type="submit" value="Insert"/></td>
        </form>
	</tr>
	<%
    while (rs.next()) {
    	Boolean deleteOK = false;
    	// check if category name has products associated with it
    	pstmt = conn.prepareStatement("SELECT ID FROM products WHERE products.category = ?");
  		pstmt.setInt(1, categoryID);
  		rs = pstmt.executeQuery();
  		if (rs.next() != null) {
  			deleteOK = true;
  		}
	%>
	<tr>
 		<form action="categories.jsp" method="POST">
	   		<td><input value="<%=rs.getString("name")%>" name="categoryName" size="20"/></td>
	    	<td><input value="<%=rs.getString("description")%>" name="description" size="40"/></td>
	    	<input type="hidden" name="action" value="update"/>
        	<input type="hidden" name="categoryID" value="<%=rs.getInt("ID")%>"/>
		    <td><input type="submit" value="Update"></td>
    	</form>
    	
    	<%
    	if (deleteOK) { 
    	%>
    	<form action="categories.jsp" method="POST">
	        <input type="hidden" name="action" value="delete"/>
	        <input type="hidden" name="categoryId" value="<%= rs.getInt("id") %>" />
	    	<td><input type="submit" value="Delete"/></td>
    	</form> 
    	<%
    	}
    	%>
	</tr>
</table>

</body>
</html>