<%@ include file="/header.jsp" %>

<title>Categories</title>
</head>

<body>

<%
// Get parameters from home.jsp
String name = (String)session.getAttribute("name");
String categoryName = request.getParameter("categoryName");
String description = request.getParameter("description");
            
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
	%>
	<tr>
 		<form action="categories.jsp" method="POST">
	   		<td><input value="<%=rs.getString("name")%>" name="categoryName" size="20"/></td>
	    	<td><input value="<%=rs.getString("description")%>" name="description" size="40"/></td>
	    	<input type="hidden" name="action" value="update"/>
        	<input type="hidden" name="categoryID" value="<%=rs.getInt("ID")%>"/>
		    <td><input type="submit" value="Update"></td>
    	</form>
    	<form action="categories.jsp" method="POST">
	        <input type="hidden" name="action" value="delete"/>
	        <input type="hidden" name="categoryId" value="<%=rs.getInt("id")%>" />
	    	<td><input type="submit" value="Delete"/></td>
    	</form>
	</tr>
</table>










<%

// INSERT Code
       
            String action = request.getParameter("action");
            // Check if an insertion is requested
            if (action != null && action.equals("insert")) {

                // Begin transaction
                conn.setAutoCommit(false);

                pstmt = conn
                .prepareStatement("INSERT INTO categories (name, description, owner) VALUES (?, ?, ?)");
                
                pstmt.setString(1, categoryName);
                pstmt.setString(2, description);
                pstmt.setInt(3, ownerID);
                int rowCount = pstmt.executeUpdate();

                // Commit transaction
                conn.commit();
                conn.setAutoCommit(true);

          %>
  <form action="confirmation.jsp" method="GET">
  	<input type="hidden" name="result" value="success"/>
  	<input type="hidden" name="action" value="insert"/>
      <input type="hidden" name="categoryName" value=<%= categoryName %>/>
<input type="hidden" name="description" value=<%= description %>/>
</form>
<%
}
%>                         

<%-- -------- UPDATE Code -------- --%>
<%
    	// get category ID for update/delete
    		selectSQL = "SELECT ID FROM categories WHERE name = ?";
pstmt = conn.prepareStatement(selectSQL);
pstmt.setString(1, name);
            rs = pstmt.executeQuery(selectSQL);
rs.next();
int categoryID = rs.getInt("ID");
        
        
        // Check if an update is requested
            if (action != null && action.equals("update")) {

                // Begin transaction
                conn.setAutoCommit(false);
                
           	    pstmt = conn
                    .prepareStatement("UPDATE categories SET name = ?, description = ?  WHERE ID = ?");

                pstmt.setString(1, categoryName);
                pstmt.setString(2, description);
                pstmt.setInt(3, categoryID);
                int rowCount = pstmt.executeUpdate();

                // Commit transaction
                conn.commit();
                conn.setAutoCommit(true);
            }
        
        //DELETE Code   
        
        if (action != null && action.equals("delete")) {

                // Begin transaction
                conn.setAutoCommit(false);

                // Create the prepared statement and use it to
                // DELETE students FROM the Students table.
                pstmt = conn
                    .prepareStatement("DELETE FROM categories WHERE ID = ?");

                pstmt.setInt(1, categoryID);
                int rowCount = pstmt.executeUpdate();

                // Commit transaction
                conn.commit();
                conn.setAutoCommit(true);
        }

        
        %>
       


<%
    }
%>

<%-- -------- Close Connection Code -------- --%>
<%
    // Close the ResultSet
    rs.close();

    // Close the Statement
    st.close();

    // Close the Connection
    conn.close();
} catch (SQLException e) {

    // Wrap the SQL exception in a runtime exception to propagate
    // it upwards
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
        </table>
        </td>
    </tr>
</table>



</body>
</html>