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
<title>Product Order</title>
</head>
<body>
<% String name = (String)session.getAttribute("name"); %>
Hello <%= name %>

<%-- set up connection --%>
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

<%-- code below adds item to cart if action was taken to do so --%>
<%
		String placeOrder = request.getParameter("placeOrder");
		String action = request.getParameter("action");
	
		//get the users's primary key ID
		conn.setAutoCommit(false);
		pstmt = conn.prepareStatement("SELECT id FROM users WHERE users.name=?");
		pstmt.setString(1, name);
		rs = pstmt.executeQuery();
		rs.next();
		int uid = rs.getInt("id");
		conn.setAutoCommit(true);
		
		if(placeOrder != null)
		{
			//begin transaction
			conn.setAutoCommit(false);
			pstmt = conn.prepareStatement("SELECT id FROM products WHERE products.name=?");
			pstmt.setString(1, placeOrder);
			rs = pstmt.executeQuery();
			rs.next();
			int pid = rs.getInt("id");
			pstmt = conn.prepareStatement("INSERT INTO inCart (id, product) VALUES (?,?)");
			pstmt.setInt(1, uid);
			pstmt.setInt(2, pid);
			
			//end transaction
			pstmt.executeUpdate();
			conn.commit();
			conn.setAutoCommit(true);
		}
	
%>

<%-- -------- UPDATE Code -------- --%>
<table>
    <tr>
		<%
            // Check if an update is requested
            if (action != null && action.equals("update")) {

                // Begin transaction
                conn.setAutoCommit(false);

                pstmt = conn.prepareStatement("UPDATE inCart SET quantity=? WHERE id=? AND product=?");
                pstmt.setInt(3, Integer.parseInt(request.getParameter("product")));
                pstmt.setInt(2, Integer.parseInt(request.getParameter("userid")));
                pstmt.setInt(1, Integer.parseInt(request.getParameter("quantity")));
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
                pstmt = conn
                    .prepareStatement("DELETE FROM inCart WHERE id=? AND product=?");

                pstmt.setInt(1, Integer.parseInt(request.getParameter("userid")));
                pstmt.setInt(2, Integer.parseInt(request.getParameter("product")));
                int rowCount = pstmt.executeUpdate();

                // Commit transaction
                conn.commit();
                conn.setAutoCommit(true);
            }
        %>
            
        <!-- Add an HTML table header row to format the results -->
        <table border="1">
        <tr>
            <th>name</th>
            <th>quantity</th>
        </tr>
            
        <%-- -------- SELECT Statement Code -------- --%>
        <%

			// Use the created statement to SELECT
			// the cart attributes FROM the inCart table.
			conn.setAutoCommit(false);
			pstmt = conn.prepareStatement("SELECT * FROM inCart WHERE inCart.id=?");
			pstmt.setInt(1, uid);
        	rs = pstmt.executeQuery();
        	conn.setAutoCommit(true);
		%>
		
		<%-- -------- Iteration Code -------- --%>
        <%
            conn.setAutoCommit(false);
        	ResultSet nameSet = null;
        	pstmt = conn.prepareStatement("SELECT name FROM products WHERE id=?");
        	// Iterate over the ResultSet
            while (rs.next()) {
        %>
        <tr>
            <form action="order.jsp" method="POST">
                <input type="hidden" name="action" value="update"/>
                <input type="hidden" name="product" value="<%=rs.getString("product")%>"/>
                <input type="hidden" name="userid" value="<%=uid%>"/>
            <td>
            <% 
            	pstmt.setInt(1, rs.getInt("product"));
            	nameSet = pstmt.executeQuery();
            	nameSet.next();
            %>
                <%=nameSet.getString("name")%>
            </td>
            <td>
                <input type="text" name="quantity" value="<%=rs.getString("quantity")%>" size="15"/>
            </td>
            <%-- Button --%>
            <td><button type="submit">Update</td>
            </form>
            <form action="order.jsp" method="POST">
                <input type="hidden" name="action" value="delete"/>
                <input type="hidden" name="product" value="<%=rs.getString("product")%>"/>
                <input type="hidden" name="userid" value="<%=uid%>"/>
                <%-- Button --%>
            <td><input type="submit" value="Delete"/></td>
            </form>
        </tr>

        <%
            }
        	nameSet.close();
        	conn.setAutoCommit(true);
        %>
        
        <%-- -------- Close Connection Code -------- --%>
        <%
            // Close the ResultSet
            rs.close();

            // Close the Connection
            conn.close();
            
    
    
    	}catch(SQLException e){
    		// Wrap the SQL exception in a runtime exception to propagate
            // it upwards
            throw new RuntimeException(e);
    	}finally{
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
    	} %>
            
	</tr>
</table>

</body>
</html>