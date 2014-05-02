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

<title>Products</title>
</head>

<body>

<%

String name = (String)session.getAttribute("sessionName");
String action = request.getParameter("action");
String category = request.getParameter("category");

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
		

// 	if (action != null && action.equals("update")) {
// 		String categoryName = request.getParameter("categoryName");
// 		String description = request.getParameter("description");
// 		int categoryID = Integer.parseInt(request.getParameter("categoryID"));

// 		// Start Transaction
// 		conn.setAutoCommit(false);
	    
// 	    pstmt = conn.prepareStatement("UPDATE categories SET name = ?, description = ?  WHERE ID = ?");
// 	    pstmt.setString(1, categoryName);
// 	    pstmt.setString(2, description);
// 	    pstmt.setInt(3, categoryID);
// 	    int rowCount = pstmt.executeUpdate();

// 	    if (rowCount > 0) {
// 		    conn.commit();
// 		    conn.setAutoCommit(true);
// 		    // End Transaction
// 	    }
// 	}	

// 	if (action != null && action.equals("delete")) {
// 		int categoryID = Integer.parseInt(request.getParameter("categoryID"));
//         // Start transaction
//         conn.setAutoCommit(false);

//         pstmt = conn.prepareStatement("DELETE FROM categories WHERE ID = ?");
//         pstmt.setInt(1, categoryID);
//         int rowCount = pstmt.executeUpdate();

//         if (rowCount > 0) {
// 	        conn.commit();
// 	        conn.setAutoCommit(true);
// 			// End transaction
//         }
// 	}
	
	// populate sidebar with valid categories
	
	pstmt = conn.prepareStatement("SELECT name FROM categories WHERE owner = ?");
	pstmt.setInt(1, ownerID);
	rs = pstmt.executeQuery();		

	ArrayList<String> categoryDrop = new ArrayList<String>();
	while (rs.next()) {
		categoryDrop.add(rs.getString("name"));
	} %>
	
	Hello <%= name %> <p/>
	
	<div style="width:200px;float:left;display:inline-block;">
		
		<div class="filter">
			<center>
			<a href="products.jsp?category=all">All Products</a></p>
			<% 
			for (int i = 0; i < categoryDrop.size(); i++) { %>
				<a href="products.jsp?category=<%= categoryDrop.get(i)%>"><%= categoryDrop.get(i)%></a></p>
			<%
			}
			%>
			</center>
		</div>
		<div class="search">
			<form action="products.jsp" method="GET">
				<input type="text" value="" name="query" size="15"/> 
				<input type="hidden" name="action" value="search"/>
				<center><input type="submit" value="Search Products"/></center>
			</form>
		</div>
	</div>
	
	<div class="content">
		<table width="80%">
			<tr>		
				<th>Name</th>
			    <th>SKU</th>
			    <th>Category</th>
			    <th>Price</th>
			</tr>
			<!--first line of table for inserting new categories -->
			<tr>
				<form action="confirmation.jsp" method="POST">
<!-- 			        <input type="hidden" name="action" value="insert"/> -->
					<td><input type="text" value="" name="productName" size="15"/></td>
			        <td><input type="text" value="" name="sku" size="15"/></td>
			     
			        <td><select name="productCategory">
					<% for (int i = 0; i < categoryDrop.size(); i++) { %>
							<option value="<%= categoryDrop.get(i)%>"><%= categoryDrop.get(i)%></option>
					<% } %>
				  		</select></td> 
			        <td><input type="text" value="" name="price" size="15"/></td>
			        <td><input type="submit" value="Insert"/></td>
		        </form>
			</tr>
			
			
			 
		</table>
 	</div>
	

<%-- 	<% --%>
// 	if (category != null && category.equals("")) {
// 		pstmt = conn.prepareStatement("SELECT * FROM products JOIN categories ON products.categories=categories.ID WHERE categories.owner = ?");
// 		pstmt.setInt(1, ownerID);
// 		rs = pstmt.executeQuery();
		
// 	} 
// 	else if (category != null) {
// 		pstmt = conn.prepareStatement("SELECT * FROM products WHERE category = ?");	
// 		pstmt.setString(1, category);
// 		rs = pstmt.executeQuery();
// 	}
	
<%-- 	while (rs.next()) {	%> --%>
		
		
<!-- 		<tr> -->
<!-- 			<form action="categories.jsp" method="POST"> 		 -->
<%-- 		   		<td><input value="<%=rs.getString("name")%>" name="productName" size="15"/></td> --%>
<%-- 		    	<td><input value="<%=rs.getString("sku")%>" name="sku" size="15"/></td> --%>
<%-- 		    	<td><input value="<%=rs.getInt("price")%>" name="price" size="15"/></td> --%>
<%-- 		    	<td><input value="<%=rs.getString("category")%>" name="productCategory" size="15"/></td> --%>
<!-- 		    	<input type="hidden" name="action" value="update"/> -->
<%-- 	        	<input type="hidden" name="productID" value="<%= rs.getInt("ID")%>"/> --%>
<!-- 			    <td><input type="submit" value="Update"></td> -->
<!-- 	   		</form> -->
<%-- 	   	</tr> <% --%>


<!-- 	} %> -->
 	
    		
	
<!-- 	// Iteration Code -->
<!-- 	while (rs.next()) { -->
<!-- 		// check if category name has products associated with it -->
<!--     	Boolean deleteOK = false; -->
<!-- 		pstmt = conn.prepareStatement("SELECT ID FROM products WHERE products.category = ?"); -->
<!--   		pstmt.setInt(1, rs.getInt("ID")); -->
<!--   		ResultSet rs2 = pstmt.executeQuery(); -->
<!--   		if (!rs2.next()) { -->
<!--   			deleteOK = true; -->
<!--   		} -->
		 
<%--     		<% --%>
<%--      		if (deleteOK) { %> --%>
<!--          		<form action="categories.jsp" method="POST"> -->
<!-- 		 	        <input type="hidden" name="action" value="delete"/> -->
<%-- 		 	        <input type="hidden" name="categoryID" value="<%= rs.getInt("ID") %>"/> --%>
<!-- 			    	<td><input type="submit" value="Delete"/></td> -->
<%--     			</form> <% --%>
<%-- 			} %> --%>
 		</tr> 
	</table> <%
// <%

	rs.close();
// 	statement.close();
	conn.close();
}
catch (SQLException e) { 
	e.printStackTrace();
	%>
	Requested data modification failed. <p/>
	<a href="products.jsp">Click here to go back to Products</a>
	<%
    
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