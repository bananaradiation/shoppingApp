<%@ page contentType="text/html; charset=utf-8" language="java"
    import="java.sql.*" import="database.*" import="java.util.*"
    errorPage=""%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Analytics with Views</title>
<script type="text/javascript" src="js/js.js" language="javascript"></script>
</head>
<body> <%
long startTime=0, finishTime=0;

// Parameter passing
    String option = (String)request.getParameter("option");
    String state = (String)request.getParameter("state");
    String categoryP = (String)request.getParameter("category");
    int category = 0;

    if (option == null) {
        option = "customers";
    }
    if (state == null) {
        state = "all";
    }
    if (categoryP != null) {
        category = Integer.parseInt(categoryP);
    }
    else {
        categoryP = "all";
    }
int i=0,j=0;
Connection conn;
try
{
    try{Class.forName("org.postgresql.Driver");}catch(Exception e){System.out.println("Driver error");}
    String url="jdbc:postgresql://localhost/project3";
    String user="postgres";
    String password="postgres";
    conn = DriverManager.getConnection(url, user, password);

    Statement row = conn.createStatement();
    Statement col = conn.createStatement();
    Statement grid = conn.createStatement();
    
    String stateList[] = {"all","Alabama","Alaska","Arizona","Arkansas",
            "California","Colorado","Connecticut","Delaware","Florida","Georgia",
            "Hawaii","Idaho","Illinois","Indiana","Iowa","Kansas","Kentucky",
            "Louisiana","Maine","Maryland","Massachusetts","Michigan","Minnesota",
            "Mississippi","Missouri","Montana","Nebraska","Nevada","New Hampshire",
            "New Jersey","New Mexico","New York","North Carolina","North Dakota",
            "Ohio","Oklahoma","Oregon","Pennsylvania","Rhode Island",
            "South Carolina","South Dakota","Tennessee","Texas","Utah","Vermont",
            "Virginia","Washington","West Virginia","Wisconsin","Wyoming"};
    ArrayList<String> states = new ArrayList<String>();

    String SQL_row="";
    startTime = System.currentTimeMillis();
    if(option.equals("customers") || option.equals("")) {        
        if (!state.equals("all") && category != 0) {
            SQL_row="SELECT name, id, total FROM (SELECT users.name, users.id, SUM(amt) AS total FROM productView, users WHERE productView.uid=users.id AND productView.cid = '"+category+"' AND users.state='"+state+"' GROUP BY users.id, users.name) AS foo ORDER BY total DESC LIMIT 20;"; 
        }
        else if (category != 0) {
        	SQL_row="SELECT name, id, total FROM (SELECT users.name, users.id, SUM(amt) AS total FROM productView, users WHERE productView.uid=users.id AND productView.cid = '"+category+"' GROUP BY users.id, users.name) AS foo ORDER BY total DESC LIMIT 20;";
        }
        else if (!state.equals("all")) {
        	SQL_row="SELECT users.name, users.id, SUM(amt) as total FROM customerView, users WHERE customerView.uid=users.id AND users.state='"+state+"' GROUP BY users.name, users.id, amt ORDER BY amt DESC LIMIT 20;";
        }
        else {
        	SQL_row="SELECT users.name, users.id, SUM(amt) as total FROM customerView, users WHERE customerView.uid=users.id GROUP BY users.name, users.id, amt ORDER BY amt DESC LIMIT 20;";
        }    
    }    
    else {
        if (!state.equals("all") && category !=0) {
            SQL_row="SELECT state, sum(amt) as total FROM stateView WHERE cid = '"+category+"' AND state = '"+state+"' GROUP BY cid, state ORDER BY sum(amt) DESC LIMIT 20";
        }
        else if (!state.equals("all")) {
            SQL_row="SELECT state, sum(amt) as total FROM stateView WHERE state = '"+state+"' GROUP BY state;";
        }
        else if (category !=0) {
            SQL_row="SELECT state, sum(amt) as total FROM stateView WHERE cid = '"+category+"' GROUP BY cid, state ORDER BY sum(amt) DESC LIMIT 20;";
        }
        else {
        	SQL_row="SELECT state, sum(amt) as total FROM stateView GROUP BY state ORDER BY sum(amt) DESC LIMIT 20;";
        }
    }
    ResultSet row_rs=row.executeQuery(SQL_row);
    finishTime = System.currentTimeMillis();
    System.out.println("Time for ROW query: " + (finishTime-startTime));
    ArrayList <String> rowName  = new ArrayList<String>();
    ArrayList <Integer> rowId  = new ArrayList<Integer>();
    ArrayList <Integer> rowTotal  = new ArrayList<Integer>();
    while (row_rs.next()) {
    	if (option.equals("customers") || option==null) {
	    	rowName.add(row_rs.getString(1));
	    	rowId.add(row_rs.getInt(2));
	    	rowTotal.add(row_rs.getInt(3));
    	}
    	else {
    		rowName.add(row_rs.getString(1));
    		rowTotal.add(row_rs.getInt(2));
    	}
    }  
    
    String SQL_col="";
    startTime = System.currentTimeMillis();
    if (!state.equals("all") && category != 0) {
        SQL_col="SELECT name, prod.id, total FROM (SELECT products.name, products.id, SUM(amt) AS total FROM productView, products, users WHERE productView.pid=products.id AND productView.uid=users.id AND productView.cid = '"+category+"' AND users.state='"+state+"' GROUP BY products.id, products.name) AS prod ORDER BY total DESC LIMIT 10;";
    }
    else if (category != 0) {
        SQL_col="SELECT prod.name, prod.id, prod.total FROM (SELECT products.name, products.id, SUM(amt) AS total FROM productView, products WHERE productView.pid=products.id AND productView.cid = '"+category+"' GROUP BY products.id, products.name) AS prod ORDER BY total DESC LIMIT 10;";
    }
    else if (!state.equals("all")) {
        SQL_col="SELECT prod.name, prod.id, prod.total FROM (SELECT products.name, products.id, SUM(amt) AS total FROM productView, products, users WHERE productView.pid=products.id AND productView.uid=users.id AND users.state='"+state+"' GROUP BY products.id, products.name) AS prod ORDER BY total DESC LIMIT 10;";
    }
    else {
        SQL_col="SELECT prod.name, prod.id, prod.total FROM (SELECT name, products.id, sum(amt) AS total FROM productView, products WHERE productView.pid=products.id GROUP BY products.id, products.name) AS prod ORDER BY total DESC LIMIT 10;";
    }
    ResultSet col_rs=col.executeQuery(SQL_col);
    finishTime = System.currentTimeMillis();
    System.out.println("Time for COL query: " + (finishTime-startTime));

    ArrayList <Integer> colId  = new ArrayList<Integer>();
    ArrayList <String> colName  = new ArrayList<String>();
    ArrayList <Integer> colTotal  = new ArrayList<Integer>();
    while (col_rs.next()) {
        colName.add(col_rs.getString(1));
        colId.add(col_rs.getInt(2));
        colTotal.add(col_rs.getInt(3));
    }
%>
    <table>
        <form action="analysis_p.jsp" method="POST">
            <tr>
                <td>Sort rows by:</td>
                <td><select name="option">
                        <option value="<%=option %>"><%=option %></option>
                        <%
            if (option.equals("customers")) { %>
                        <option value="states">states</option>
                        <%
            } 
            else { %>
                        <option value="customers">customers</option>
                        <%  
            }
            %>

                </select></td>
            </tr>
        <tr>
            <td>Filter sales by:</td>
        </tr>
        <tr>
            <td>State:</td>
            <td><select name="state">
            
                    <option value="<%=state %>"><%=state %></option>
                    <%
            for (i = 0; i < 50; i++) {
                if (!stateList[i].equals(state)) { %>
                    <option value="<%=stateList[i]%>"><%=stateList[i]%></option>
                    <% } } %>
            </select></td>
        </tr>
        <%
        Statement stmtCategory = conn.createStatement();
        ResultSet rsCategory=stmtCategory.executeQuery("SELECT name, id FROM categories");
        ArrayList<String> categoryDropS = new ArrayList<String>();
        ArrayList<Integer> categoryDrop = new ArrayList<Integer>();
        categoryDropS.add("all");
        categoryDrop.add(0);
        while (rsCategory.next()) {
            categoryDropS.add(rsCategory.getString("name"));
            categoryDrop.add(rsCategory.getInt("id"));
        }  
        categoryP = categoryDropS.get(category); %>
        <tr>
            <td>Category:</td>
            <td><select name="category">
                    <option value="<%=category %>"><%=categoryP %></option>
                    <% for (j = 0; j < categoryDrop.size(); j++) { 
               if (!categoryDrop.get(j).equals(category)) { %>
                    <option value="<%= categoryDrop.get(j)%>"><%= categoryDropS.get(j)%></option>
                    <% } } %>
            </select></td>
        </tr>
            <td><button type="submit">Run Query</button></td>
        </tr>
        </form>
    </table>
    <%
 %>

<table align="center" width="98%" border="1">
    <tr align="center">
        <%
    String SQL_grid="";
    if (option.equals("states")) { %>
        <td><strong><font color="#FF0000">STATE</font></strong></td>
        <% 
        SQL_grid="select sum(amt) as amt from productView, products, users where productView.pid=products.id and productView.pid=? and productView.uid=users.id and users.state=? group by products.name;";   
    }
    else if (option.equals("customers")) { %>
        <td><strong><font color="#FF0000">CUSTOMERS</font></strong></td>
        <% 
        SQL_grid="select amt from productView, products, users where productView.pid=products.id and productView.pid=? and productView.uid=? group by products.name, productView.amt";
        }
    
    for (int c=0; c<10; c++) { %>
    	<td align="center"><strong><%= colName.get(c) %> (<%= colTotal.get(c) %>)</strong></td> <%
    }
    PreparedStatement pstmt = conn.prepareStatement(SQL_grid);
    ResultSet grid_rs;
    for (int r=0; r<rowTotal.size(); r++) {
    	grid_rs = null;
    	if (!option.equals("states")) {
    		pstmt.setInt(2,rowId.get(r));
    	}
    	else {
    	    pstmt.setString(2,rowName.get(r));
    	} %>
    	
    	<tr><td align="center"><strong><%=rowName.get(r) %> (<%=rowTotal.get(r) %>)</strong></td>
    	<%
    	for (int g=0; g<colId.size(); g++) {
    		pstmt.setInt(1, colId.get(g));
    		grid_rs = pstmt.executeQuery();
    		if (grid_rs.next()) { %>
    	   	<td align="center"><%=grid_rs.getInt("amt") %></td>
    	<%
    		}
    		else {%>
            <td align="center">0</td>
            <%
    		}
    	}
    }
finishTime = System.currentTimeMillis();
System.out.println("Time for GRID query: " + (finishTime-startTime)); %>
    
    <form action="analysis_p.jsp" method="GET">
        <tr><td align="center">
        <button type="submit">Analytics Home</button></td></tr>
    </form>
</table>
<% 
}
catch(Exception e) { 
    out.println(e.getMessage()); 
}
finally {
    System.out.println("End query");
//     conn.close(); 
}   
%>
</body>
</html>