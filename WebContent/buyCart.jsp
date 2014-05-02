<%@include file="header.jsp" %>

<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@ page import="java.util.*"%>
<%@ page import="java.io.*"%>
<%@ page import="java.sql.*" %>
<%@ page import="org.postgresql.*" %>
<%@ page import="java.text.DecimalFormat" %>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Buy Cart</title>
</head>
<body>
<% String name = (String)session.getAttribute("sessionName"); %>
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

<%-- code below displays user's cart and total cost --%>
<%
	//string for checking if the user pressed the buy button
	//String action = request.getParameter("action");
			
	//get the users's primary key ID
	conn.setAutoCommit(false);
	pstmt = conn.prepareStatement("SELECT id FROM users WHERE users.name=?");
	pstmt.setString(1, name);
	rs = pstmt.executeQuery();
	rs.next();
	int uid = rs.getInt("id");
	conn.setAutoCommit(true);
	
	
	double totalPrice = 0;
	if(action != null && action.equals("buy"))
	{
		%>, you have successfully purchased <%
	}
%>
<table border="1">
        <tr>
            <th>name</th>
            <th>quantity</th>
            <th>price</th>
        </tr>
	<%-- -------- SELECT Statement Code -------- --%>
    <%

		// Use the created statement to SELECT
		// the cart attributes FROM the inCart table.
		conn.setAutoCommit(false);
		pstmt = conn.prepareStatement("SELECT * FROM inCart WHERE inCart.id=?");
		pstmt.setInt(1, uid);
        rs = pstmt.executeQuery();
        
        ResultSet prices = null;
        PreparedStatement priceStmt = conn.prepareStatement("SELECT price FROM products WHERE id=?");
        DecimalFormat df = new DecimalFormat("#.##");
        conn.setAutoCommit(true);
	%>
	
	<%
        conn.setAutoCommit(false);
        ResultSet nameSet = null;
        pstmt = conn.prepareStatement("SELECT name FROM products WHERE id=?");
        // Iterate over the ResultSet
        while (rs.next()) {
        %>
        <tr>
            <td>
            <% 
            	pstmt.setInt(1, rs.getInt("product"));
            	nameSet = pstmt.executeQuery();
            	nameSet.next();
            %>
                <%=nameSet.getString("name")%>
            </td>
            <td>
                <%=rs.getString("quantity")%>
            </td>
            <td>
            <% 
            	priceStmt.setInt(1, rs.getInt("product"));
            	prices = priceStmt.executeQuery();
            	prices.next();
            	totalPrice = totalPrice + Integer.parseInt(rs.getString("quantity"))
                    	* Double.parseDouble(prices.getString("price"));
            %>
                <%=df.format(Integer.parseInt(rs.getString("quantity"))
                	* Double.parseDouble(prices.getString("price")))%>
            </td>
            
        </tr>
        <%
            }
        	if(nameSet != null){ nameSet.close();}
        	if(prices != null){ prices.close();}
        	conn.setAutoCommit(true);
        	if(action != null && action.equals("buy")){
        		%> for $<%=totalPrice%>:
        		<p align="right"><a href="/ShoppingApplication/browse.jsp">Return to Product Browsing</a></p><%
        	}
        	else {
        %>
        </table>
        Total cost is $<%=totalPrice%>:<br>
        Credit Card Number: <br>
		<form action="buyCart.jsp" method=POST>
			<input type="hidden" name="action" value="buy"/>
			<input type="text" name="ccNum" size="15"/>
			<button type="submit">Purchase</button>
		</form>
		<% 
        	}
        	
		if(action != null && action.equals("buy"))
		{
			conn.setAutoCommit(false);
			pstmt = conn.prepareStatement("UPDATE users SET creditCard=? WHERE id=?");
			pstmt.setString(1, (String)request.getAttribute("ccNum"));
			pstmt.setInt(2, uid);
			pstmt.executeUpdate();
			pstmt = conn.prepareStatement("DELETE FROM inCart WHERE id=?");
			pstmt.setInt(1, uid);
			pstmt.executeUpdate();
	        // Commit transaction
	        conn.commit();
	        conn.setAutoCommit(true);
			}
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
            

</body>
</html>