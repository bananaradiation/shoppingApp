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
<title>Product Browsing</title>
</head>
<body>
<% String name = (String)session.getAttribute("name"); 
	String searchItem = request.getParameter("search");
	String categoryFilter = request.getParameter("category");
	String searchBoxString;
	if(searchItem != null)
	{
		searchBoxString = searchItem;
	}
	else
	{ 
		searchBoxString = "search";
	}
%>
Hello <%= name %>
<form action="browse.jsp" method="GET">
	<%if(categoryFilter != null && !categoryFilter.equals("All producst")){ %>
	<input type="hidden" name="category" value=<%=categoryFilter%>>
	<%} %>
	<input type="text" name="search" value= <%=searchBoxString%>>
<button type="submit">go</button>
</form> 
<%-- below is the section that displays a list of categories --%>
<%
	Connection conn = null;
	PreparedStatement pstmt = null;
    ResultSet rs = null;
    //arrayList for storing list of categores for display
    ArrayList<String> categories = new ArrayList<String>();
    
    try {
        // Registering Postgresql JDBC driver with the DriverManager
        Class.forName("org.postgresql.Driver");

        // Open a connection to the database using DriverManager
        conn = DriverManager.getConnection(
            "jdbc:postgresql://localhost/cse135?" +
            "user=postgres&password=postgres");
        
        //begin transaction
        conn.setAutoCommit(false);
        //retrieve categories
        pstmt = conn.prepareStatement("SELECT name FROM categories;");
        //end transaction
        rs = pstmt.executeQuery();
        conn.setAutoCommit(true);
        
        while(rs.next())//put categories into arraylist for display
        {
        	categories.add(rs.getString("name"));
        }
    
    
    //display categories
    %><form action='browse.jsp' action='GET'>
    <%if(searchItem != null){ %>
    	<input type="hidden" name="search" value= <%=searchBoxString%>>
    <%} %>
    	<input type="submit" name="category" value='All products'>
    <%
    for(int i = 0; i < categories.size(); i++)
    {
    	%>
    		<br><input type="submit" name="category" value=<%=categories.get(i)%>>
		</form><%
    }
    
%>

<%-- below is the part that displays products --%>
<%
		int catf = 0;
		if(categoryFilter != null && !categoryFilter.equals("All products"))
		{
			conn.setAutoCommit(false);
			//retrieve categories
			pstmt = conn.prepareStatement("SELECT id FROM categories WHERE name=?;");
			pstmt.setString(1, categoryFilter);
			//end transaction
			rs = pstmt.executeQuery();
			conn.setAutoCommit(true);
			rs.next();
			catf = rs.getInt("id");
		}
		ArrayList<Integer> catid = new ArrayList<Integer>();
		while(rs.next())
		{
			catid.add(rs.getInt("id"));
		}
	
		//begin transaction
		conn.setAutoCommit(false);
		if(categoryFilter != null && searchItem != null && !categoryFilter.equals("All products"))
		{
			pstmt = conn.prepareStatement(
				"SELECT name, sku, price, category FROM products WHERE products.category=? AND products.name LIKE ?");
			pstmt.setInt(1, catf);
			pstmt.setString(2, "%"+searchItem+"%");
		} else if (searchItem != null){
			pstmt = conn.prepareStatement(
				"SELECT name, sku, price, category FROM products WHERE products.name LIKE ?");
			pstmt.setString(1, "%"+searchItem+"%");
		} else if (categoryFilter != null && !categoryFilter.equals("All products")){
			pstmt = conn.prepareStatement(
				"SELECT name, sku, price, category FROM products WHERE products.category=?");
			pstmt.setInt(1, catf);
		} else {
			pstmt = conn.prepareStatement("SELECT name, sku, price, category FROM products;");
		}
		//end transaction
		rs = pstmt.executeQuery();
		conn.setAutoCommit(true);
		
		//form currently used to be able to select items for order
		%> <form action=order.jsp method="POST"> <%
		ResultSet catRef = null;//used to get names of categories
		//display items
		conn.setAutoCommit(false); //setup transactions for getting categories
		while(rs.next())
		{
			pstmt = conn.prepareStatement("SELECT name FROM categories WHERE categories.ID=?");
			pstmt.setInt(1, rs.getInt("category"));
			catRef = pstmt.executeQuery();
			catRef.next();
			%> <input name="placeOrder" type="submit" value="<%=rs.getString("name")%>"> 
				<%=rs.getString("sku") %> $<%=rs.getString("price") %> <%=catRef.getString("name") %> <%
		}
		conn.setAutoCommit(true);//transactions completed after loop
		%> </form><%
		// Close the ResultSet
        rs.close();

        // Close the Statement
        pstmt.close();

        // Close the Connection
        conn.close();
	} catch (SQLException e){} finally{}
%>
</body>
</html>