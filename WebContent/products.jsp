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
<title>Products Page</title>
</head>

<body>

	<% String name = (String)session.getAttribute("name");
	
	%>
<table>
    <tr>

        <td>
            <%-- -------- Open Connection Code -------- --%>
            <%
            
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
            %>
            
            <%-- -------- INSERT Code -------- --%>
            <%
                String action = request.getParameter("action");
                // Check if an insertion is requested
                if (action != null && action.equals("insert")) {

                    // Begin transaction
                    conn.setAutoCommit(false);

                    // Create the prepared statement and use it to
                    // INSERT student values INTO the students table.
                    pstmt = conn
                    .prepareStatement("INSERT INTO products (name, sku, price, category, owner) VALUES (?, ?, ?, ?, ?)");

                    pstmt.setString(1, request.getParameter("name"));
                    pstmt.setString(2, request.getParameter("sku"));
                    pstmt.setInt(3, Integer.parseInt(request.getParameter("price")));
                    pstmt.setString(4, request.getParameter("category"));
                    pstmt.setString(5, request.getParameter("owner"));
                    int rowCount = pstmt.executeUpdate();                  
                    
                    // Commit transaction
                    conn.commit();
                    conn.setAutoCommit(true);
%>
                    // set action to success
                    <form action="confirmation.jsp" method="GET">
                         <input type="hidden" name="action" value="success"/>
                         <input type="hidden" name="name" value="name"/>
                         <input type="hidden" name="sku" value="sku"/>
                         <input type="hidden" name="price" value="price"/>
                         <input type="hidden" name="categpru" value="category"/>
                    </form>
  <%              }
            %>
            
            <%-- -------- UPDATE Code -------- --%>
            <%
                // Check if an update is requested
                if (action != null && action.equals("update")) {

                    // Begin transaction
                    conn.setAutoCommit(false);

                    // Create the prepared statement and use it to
                    // UPDATE student values in the Students table.
                    pstmt = conn
                        .prepareStatement("UPDATE students SET pid = ?, first_name = ?, "
                            + "middle_name = ?, last_name = ? WHERE id = ?");

                    pstmt.setInt(1, Integer.parseInt(request.getParameter("pid")));
                    pstmt.setString(2, request.getParameter("first"));
                    pstmt.setString(3, request.getParameter("middle"));
                    pstmt.setString(4, request.getParameter("last"));
                    pstmt.setInt(5, Integer.parseInt(request.getParameter("id")));
                    int rowCount = pstmt.executeUpdate();

                    // Commit transaction
                    conn.commit();
                    conn.setAutoCommit(true);
                }
            %>
            
            <%-- -------- DELETE Code -------- --%>
            <%
                // Check if a delete is requested
                if (action != null && action.equals("delete")) {

                    // Begin transaction
                    conn.setAutoCommit(false);

                    // Create the prepared statement and use it to
                    // DELETE students FROM the Students table.
                    pstmt = conn
                        .prepareStatement("DELETE FROM Students WHERE id = ?");

                    pstmt.setInt(1, Integer.parseInt(request.getParameter("id")));
                    int rowCount = pstmt.executeUpdate();

                    // Commit transaction
                    conn.commit();
                    conn.setAutoCommit(true);
                }
            %>

            <%-- -------- SELECT Statement Code -------- --%>
            <%
                // Create the statement
                Statement statement = conn.createStatement();

                rs = statement.executeQuery("SELECT categories.name FROM ((categories JOIN products ON categories.ID=products.category) JOIN users on products.owner=users.ID) WHERE users.name=name");
            %>
            
            <!-- Add an HTML table header row to format the results -->
            <table border="1">
            <tr>
                <th>Name</th>
                <th>SKU</th>
                <th>Category</th>
                <th>Price</th>
            </tr>

            <tr>
                <form action="products.jsp" method="POST">
                    <input type="hidden" name="action" value="insert"/>
                    <th>&nbsp;</th>
                    <th><input value="" name="name" size="10"/></th>
                    <th><input value="" name="sku" size="15"/></th>
                    <th><input value="" name="price" size="15"/></th>
                    <th><select name="category">
						<% while(rs.next()) { 
							String category = rs.getString("category"); %>
							<option value="<%= category %>"><%= category %></option>
						<% } %>
			  			</select>
                    <th><input value="" name="owner" size="15"/></th>
                    <th><input type="submit" value="Insert"/></th>
                </form>
            </tr>

<%--             -------- Iteration Code -------- --%>
<%--             <% --%>
//                 // Iterate over the ResultSet
//                 while (rs.next()) {
<%--             %> --%>

<!--             <tr> -->
<!--                 <form action="attempt3/students.jsp" method="POST"> -->
<!--                     <input type="hidden" name="action" value="update"/> -->
<%--                     <input type="hidden" name="id" value="<%=rs.getInt("id")%>"/> --%>

<%--                 Get the id --%>
<!--                 <td> -->
<%--                     <%=rs.getInt("id")%> --%>
<!--                 </td> -->

<%--                 Get the pid --%>
<!--                 <td> -->
<%--                     <input value="<%=rs.getInt("pid")%>" name="pid" size="15"/> --%>
<!--                 </td> -->

<%--                 Get the first name --%>
<!--                 <td> -->
<%--                     <input value="<%=rs.getString("first_name")%>" name="first" size="15"/> --%>
<!--                 </td> -->

<%--                 Get the middle name --%>
<!--                 <td> -->
<%--                     <input value="<%=rs.getString("middle_name")%>" name="middle" size="15"/> --%>
<!--                 </td> -->

<%--                 Get the last name --%>
<!--                 <td> -->
<%--                     <input value="<%=rs.getString("last_name")%>" name="last" size="15"/> --%>
<!--                 </td> -->

<%--                 Button --%>
<!--                 <td><input type="submit" value="Update"></td> -->
<!--                 </form> -->
<!--                 <form action="attempt3/students.jsp" method="POST"> -->
<!--                     <input type="hidden" name="action" value="delete"/> -->
<%--                     <input type="hidden" value="<%=rs.getInt("id")%>" name="id"/> --%>
<%--                     Button --%>
<!--                 <td><input type="submit" value="Delete"/></td> -->
<!--                 </form> -->
<!--             </tr> -->

<%--             <% --%>
//                 }
<%--             %> --%>

            <%-- -------- Close Connection Code -------- --%>
            <%
                // Close the ResultSet
                rs.close();

                // Close the Statement
                statement.close();

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

</body>

</html>