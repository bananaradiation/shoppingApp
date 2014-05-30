<%@ page contentType="text/html; charset=utf-8" language="java"
    import="java.sql.*" import="database.*" import="java.util.*"
    errorPage=""%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>CSE135</title>
<script type="text/javascript" src="js/js.js" language="javascript"></script>
</head>
<body> <%
long startTime=0, finishTime=0;

// Parameter passing
    String option = (String)request.getParameter("option");
    String state = (String)request.getParameter("state");
    String categoryP = (String)request.getParameter("category");
    int category = 0;
    String age = (String)request.getParameter("age");
    String rowPg = (String)request.getParameter("rowPage");
    String colPg = (String)request.getParameter("colPage");
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
    if (age == null) {
        age = "all";
    }
    if (rowPg == null) {
        rowPg = "1";
    }
    if (colPg == null) {
        colPg = "1";
    }

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
for (int i = 0; i < 50; i++) {
    states.add(stateList[i]);
}

class Item {
    private int id=0;
    private String name=null;
    private float amount_price=0f;
    public int getId() {
        return id;
    }
    public void setId(int id) {
        this.id = id;
    }
    public String getName() {
        return name;
    }
    public void setName(String name) {
        this.name = name;
    }
    public float getAmount_price() {
        return amount_price;
    }
    public void setAmount_price(float amount_price) {
        this.amount_price = amount_price;
    }
}

ArrayList<Item> p_list=new ArrayList<Item>();
ArrayList<Item> s_list=new ArrayList<Item>();
Item item=null;
Connection conn=null;
Statement row_stmt, col_stmt, grid_stmt, temp_row, temp_col, temp_grid;
ResultSet row_rs=null, col_rs=null, grid_rs=null;

try
{
    try{Class.forName("org.postgresql.Driver");}catch(Exception e){System.out.println("Driver error");}
    String url="jdbc:postgresql://localhost/cse135";
    String user="postgres";
    String password="postgres";
    conn = DriverManager.getConnection(url, user, password);
    row_stmt = conn.createStatement();
    col_stmt = conn.createStatement();
    grid_stmt = conn.createStatement();
    
 String start_row = "";
 String end_row = "";
 String temp_start = "CREATE TEMPORARY TABLE users_temp AS ";
 String temp_end = "";

 String sql_base = "SUM(quantity * sales.price) AS AMOUNT FROM users_temp LEFT OUTER JOIN sales ON sales.uid = users_temp.id GROUP BY users_temp.id, users_temp.name, users_temp.state ";
 String sql_prod = "SUM(quantity * sales.price) AS AMOUNT FROM users_temp LEFT OUTER JOIN sales ON sales.uid = users_temp.id JOIN products ON sales.pid=products.id JOIN categories ON categories.id=products.cid WHERE categories.id="+category+" GROUP BY users_temp.id, users_temp.name ";
 
 startTime = System.currentTimeMillis();
 temp_row = conn.createStatement();
    if(option.equals("customers") || option.equals("")) {
    	start_row = "SELECT users_temp.name, ";
    	end_row = "ORDER BY users_temp.name asc";
    	temp_end = "ORDER BY name asc LIMIT 20 "+"offset "+(Integer.parseInt(rowPg)-1)*20+");";

	    if (!age.equals("all") && !state.equals("all")) {
            String temp5 = "(SELECT * FROM users WHERE state='"+state+"' AND age BETWEEN "+age+ temp_end;
            temp_row.execute(temp_start+temp5);
        }
	    else if (!state.equals("all")) {
	    	String temp4 = "(SELECT * FROM users WHERE state='"+state+"'"+ temp_end;
	        temp_row.execute(temp_start+temp4);
	    }
	    else if (!age.equals("all")) {
	        String temp2 = "(SELECT * FROM users WHERE age BETWEEN "+age + temp_end;
	        temp_row.execute(temp_start+temp2);
	    }
	    else {
	        String temp1 = "(SELECT * FROM users " + temp_end;
	        temp_row.execute(temp_start+temp1);
	    }
	    if(category != 0)
	    {
        	row_rs=row_stmt.executeQuery(start_row+/*sql_base*/sql_prod+end_row);
	    }
	    else
	    {
	    	row_rs=row_stmt.executeQuery(start_row+sql_base+end_row);
	    }
    }
	else {

        
        String state_end = " group by u.state order by u.state asc limit 20 "+"offset "+(Integer.parseInt(rowPg)-1)*20+";";
        if(category != 0)
        {
        	state_end = " AND p.cid="+category+state_end;
        }
        String SQL_state = "SELECT u.state, SUM(quantity * p.price) AS AMOUNT FROM products p, users u LEFT OUTER JOIN sales ON sales.uid = u.id WHERE sales.pid = p.id ";
        
        String SQL_state_age="select u.state, sum(s.quantity*p.price) as amount from users u, sales s,  products p where s.uid=u.id and s.pid=p.id and u.age between "+age+ state_end;
        String SQL_state_state_age="select u.state, sum(s.quantity*p.price) as amount from users u, sales s,  products p where s.uid=u.id and s.pid=p.id and u.age between "+age+" and u.state='"+state+"'"+ state_end;
        
        if (!state.equals("all") && !age.equals("all")) {
            row_rs=row_stmt.executeQuery(SQL_state_state_age);
        }
        else if (!state.equals("all")) {
        	String temp_state = "CREATE TEMPORARY TABLE temp_state AS (SELECT id, state FROM users WHERE state='"+state+"');";
        	temp_row.execute(temp_state);
        	String SQL_state1 = "SELECT state, SUM(quantity * price) AS AMOUNT FROM temp_state JOIN sales ON sales.uid = temp_state.id GROUP BY state;";
            row_rs=row_stmt.executeQuery(SQL_state1);
        }
        else if (!age.equals("all")) {
            row_rs=row_stmt.executeQuery(SQL_state_age);
        }
        else {
            row_rs=row_stmt.executeQuery(SQL_state+state_end);
        }
        
    }
    finishTime = System.currentTimeMillis();
    System.out.println("Time for ROW query: " + (finishTime-startTime));
    
    String prod_temp1 = "CREATE TEMPORARY TABLE products_temp AS (SELECT * FROM products ORDER BY name asc LIMIT 10 "+"offset "+(Integer.parseInt(colPg)-1)*10+");";
    String prod_temp2 = "CREATE TEMPORARY TABLE products_temp AS (SELECT products.name, products.id, products.cid, products.price FROM products JOIN categories ON products.cid=categories.id WHERE categories.id="+category+" ORDER BY name asc LIMIT 10 "+"offset "+(Integer.parseInt(colPg)-1)*10+");";
    Statement temp_prod_stmt=conn.createStatement();
    String sql_prod_base = "SELECT products_temp.name, SUM(sales.quantity * sales.price) AS AMOUNT FROM products_temp LEFT OUTER JOIN sales ON sales.pid = products_temp.id GROUP BY products_temp.id, products_temp.name ORDER BY products_temp.name;";

    startTime = System.currentTimeMillis();
    if (category != 0) {
        temp_prod_stmt.execute(prod_temp2);
    }
    else {
        temp_prod_stmt.execute(prod_temp1);
    }
    col_rs=col_stmt.executeQuery(sql_prod_base);
    finishTime = System.currentTimeMillis();
    System.out.println("Time for COL query: " + (finishTime-startTime));
    
    
    int p_id=0;
    String p_name=null;
    float p_amount_price=0;
    while(col_rs.next()) {
//         p_id=col_rs.getInt(1);
        p_name=col_rs.getString(1);
        p_amount_price=col_rs.getFloat(2);
        item=new Item();
//         item.setId(p_id);
        item.setName(p_name);
        item.setAmount_price(p_amount_price);
        p_list.add(item);
    }
    String s_name=null;
    float s_amount_price=0;
    while(row_rs.next()) {
        s_name=row_rs.getString(1);
        s_amount_price=row_rs.getFloat(2);
        item=new Item();
        item.setName(s_name);
        item.setAmount_price(s_amount_price);
        s_list.add(item);
    }
    
int i=0,j=0;
float amount=0; 
    
// set dashboard
    boolean showDashboard = true;
    if (Integer.parseInt(rowPg) != 1) {
        showDashboard = false;  
    }
    else if (Integer.parseInt(colPg) != 1) {
        showDashboard = false;
    } 

if (showDashboard) { %>
    <table>
        <form action="analytics_new.jsp" method="POST">
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

        <% ArrayList<String> ageDrop = new ArrayList<String>();
        ageDrop.add("all");
        ageDrop.add("12 and 18");
        ageDrop.add("18 and 45");
        ageDrop.add("45 and 65"); 
        ageDrop.add("65 and 1000"); %>
        <tr>
            <td>Age:</td>
            <td><select name="age">
                    <option value="<%=age%>"><%=age %></option>
                    <% 
             for (j = 0; j < ageDrop.size(); j++) { 
               if (!ageDrop.get(j).equals(age)) { %>
                    <option value="<%= ageDrop.get(j)%>"><%= ageDrop.get(j)%></option>
                    <% } } %>
            </select></td>
        <tr>
            <td><button type="submit">Run Query</button></td>
        </tr>
        </form>
    </table>
    <%
} %>

<table align="center" width="98%" border="1">
    <tr align="center">
        <%
    if (option.equals("states")) { %>
        <td><strong><font color="#FF0000">STATE</font></strong></td>
        <% }
    else if (option.equals("customers")) { %>
        <td><strong><font color="#FF0000">CUSTOMERS</font></strong></td>
        <% }

// displays product aggregation headers in grid
for(i=0;i<p_list.size();i++) {
    p_id            =   p_list.get(i).getId();
    p_name          =   p_list.get(i).getName();
    p_amount_price  =   p_list.get(i).getAmount_price();
    out.print("<td> <strong>"+p_name+"<br>("+p_amount_price+")</strong></td>");
} %>
    </tr> <%  

startTime = System.currentTimeMillis();
String tabOff, tabsql, productname;
int[] tabOffset = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
if(request.getParameter("tableOffset0") != null)
{
	for (int off=0;off<20;off++) {
		tabOffset[off] = Integer.parseInt(request.getParameter("tableOffset"+off));
	}
}

for(i=0; i<s_list.size(); i++)
{
	s_name          =   s_list.get(i).getName();
    s_amount_price  =   s_list.get(i).getAmount_price();
//     displays row aggregation headers in grid
    out.println("<tr  align=\"center\">");
    out.println("<td><strong>"+s_name+" ("+s_amount_price+")</strong></td>");   
   

    
    
    
//  original sql
// 	tabsql ="SELECT p.name AS productname, sum(s.quantity * p.price) AS amount, p.id as prodID "+
// 			"FROM sales s, products_temp p, users_temp u, categories c "+
// 			"WHERE p.id = s.pid AND u.id = s.uid AND c.id = p.cid ";
			
    //nested sql in FROM clause
// 	tabsql = "SELECT p.name AS productname, sum(s.quantity * p.price) AS amount "+
//             "FROM sales s, products_temp p, users_temp u, (SELECT * FROM categories c WHERE c.name = '"+category+"') cat" +
//             "WHERE p.id = s.pid AND u.id = s.uid AND categories.id = p.cid"
    
            
    //String nested_where = "(SELECT c.id FROM categories c WHERE c.id = "+category+") ";
    
    if( category != 0 ) {
	    tabsql ="SELECT p.name AS productname, sum(s.quantity * p.price) AS amount, p.id as prodID "+
     "FROM sales s, products_temp p, users_temp u, categories c "+
     "WHERE p.id = s.pid AND u.id = s.uid AND c.id = p.cid AND c.id = "+category+"" ;

	    tabsql ="SELECT p.name AS productname, sum(s.quantity * p.price) AS amount "+
	            "FROM sales s, products_temp p, users_temp u "+
	            "WHERE p.id = s.pid AND u.id = s.uid ";
		if("customers".equals(option) || "".equals(option)) {
            tabsql = tabsql + "AND u.name = '"+s_name+"' ";
        }
        else if ("states".equals(option)) {
        	tabsql ="SELECT p.name AS productname, sum(s.quantity * p.price) AS amount "+
    	            "FROM sales s, products_temp p, users u "+
    	            "WHERE p.id = s.pid AND u.id = s.uid ";
            tabsql = tabsql + "AND u.state = '"+s_name+"' ";
        }    
		tabsql = tabsql + "AND p.cid = " + category;
	}
	else {
		tabsql ="SELECT p.name AS productname, sum(s.quantity * p.price) AS amount "+
	          "FROM sales s, products_temp p, users_temp u, categories c "+
	          "WHERE p.id = s.pid AND u.id = s.uid AND c.id = p.cid ";
		if("customers".equals(option) || "".equals(option)) {
            tabsql = tabsql+ "AND u.name = '"+s_name+"' ";
        }
	    else if ("states".equals(option)) {
	    	tabsql ="SELECT p.name AS productname, sum(s.quantity * p.price) AS amount "+
		            "FROM sales s, products_temp p, users u "+
		            "WHERE p.id = s.pid AND u.id = s.uid ";
            tabsql = tabsql+ "AND u.state = '"+s_name+"' ";
        }
	}

    tabsql = tabsql + "GROUP BY p.name, u.state "+
			"ORDER BY p.name "+
			"LIMIT 20 OFFSET " + tabOffset[i] + ";";
			
	grid_rs = grid_stmt.executeQuery(tabsql);
	boolean flag = grid_rs.next();
		String inner;
        for(j = 0; j < p_list.size(); j++)
		{
			p_name = p_list.get(j).getName();
			if (flag) {
				productname = grid_rs.getString(1);
				if(productname.equals(p_name))
				{
					amount=grid_rs.getFloat(2);
		            out.print("<td><font color='#0000ff'>"+amount+"</font></td>");
		            tabOffset[i]++;
		            flag = grid_rs.next();
				}
				else
				{
					out.println("<td><font color='#ff0000'>0</font></td>");
				}
			}
			else {
				out.println("<td><font color='#ff0000'>0</font></td>");
			}
		}
	out.println("</tr>");
}

finishTime = System.currentTimeMillis();
System.out.println("Time for GRID query: " + (finishTime-startTime)); %>
    <form action="analytics_new.jsp" method="GET">
        <tr>
            <td align="center">
                <% 
     if (s_list.size() >= 20) {
         if (option.equals("states")) { %>
                <button type="submit" align="center">Next 20 States</button> <% } 
         else { %>
                <button type="submit">Next 20 Customers</button> <%
         }
     } %> <input type="hidden" name="rowPage"
                value="<%=Integer.parseInt(rowPg)+1 %>" /> <input type="hidden"
                name="colPage" value="<%=Integer.parseInt(colPg) %>" /> <input
                type="hidden" name="age" value="<%=age %>" /> <input type="hidden"
                name="state" value="<%=state %>" /> <input type="hidden"
                name="category" value="<%=category %>" /> <input type="hidden"
                name="option" value="<%=option %>" />
          <input type="hidden" name="tableOffset0" value=<%=tabOffset[0]%> />
          <input type="hidden" name="tableOffset1" value=<%=tabOffset[1]%> />
          <input type="hidden" name="tableOffset2" value=<%=tabOffset[2]%> />
          <input type="hidden" name="tableOffset3" value=<%=tabOffset[3]%> />
          <input type="hidden" name="tableOffset4" value=<%=tabOffset[4]%> />
          <input type="hidden" name="tableOffset5" value=<%=tabOffset[5]%> />
          <input type="hidden" name="tableOffset6" value=<%=tabOffset[6]%> />
          <input type="hidden" name="tableOffset7" value=<%=tabOffset[7]%> />
          <input type="hidden" name="tableOffset8" value=<%=tabOffset[8]%> />
          <input type="hidden" name="tableOffset9" value=<%=tabOffset[9]%> />
          <input type="hidden" name="tableOffset10" value=<%=tabOffset[10]%> />
          <input type="hidden" name="tableOffset11" value=<%=tabOffset[11]%> />
          <input type="hidden" name="tableOffset12" value=<%=tabOffset[12]%> />
          <input type="hidden" name="tableOffset13" value=<%=tabOffset[13]%> />
          <input type="hidden" name="tableOffset14" value=<%=tabOffset[14]%> />
          <input type="hidden" name="tableOffset15" value=<%=tabOffset[15]%> />
          <input type="hidden" name="tableOffset16" value=<%=tabOffset[16]%> />
          <input type="hidden" name="tableOffset17" value=<%=tabOffset[17]%> />
          <input type="hidden" name="tableOffset18" value=<%=tabOffset[18]%> />
          <input type="hidden" name="tableOffset19" value=<%=tabOffset[19]%> />
          
            </td>
    </form>
    <form action="analytics_new.jsp" method="GET">
        <tr>
            <td align="center">
                <% 
     if (p_list.size() >= 10) { %>
                <button type="submit">Next 10 Products</button>
        </tr>
        <%
     } %>
        <input type="hidden" name="colPage"
            value="<%=Integer.parseInt(colPg)+1 %>" /> <input type="hidden"
            name="rowPage" value="<%=Integer.parseInt(rowPg) %>" /> <input
            type="hidden" name="age" value="<%=age %>" /> <input type="hidden"
            name="state" value="<%=state %>" /> <input type="hidden"
            name="category" value="<%=category %>" /> <input type="hidden"
            name="option" value="<%=option %>" />
        <input type="hidden" name="tableOffset0" value=<%=tabOffset[0]%> />
          <input type="hidden" name="tableOffset1" value=<%=tabOffset[1]%> />
          <input type="hidden" name="tableOffset2" value=<%=tabOffset[2]%> />
          <input type="hidden" name="tableOffset3" value=<%=tabOffset[3]%> />
          <input type="hidden" name="tableOffset4" value=<%=tabOffset[4]%> />
          <input type="hidden" name="tableOffset5" value=<%=tabOffset[5]%> />
          <input type="hidden" name="tableOffset6" value=<%=tabOffset[6]%> />
          <input type="hidden" name="tableOffset7" value=<%=tabOffset[7]%> />
          <input type="hidden" name="tableOffset8" value=<%=tabOffset[8]%> />
          <input type="hidden" name="tableOffset9" value=<%=tabOffset[9]%> />
          <input type="hidden" name="tableOffset10" value=<%=tabOffset[10]%> />
          <input type="hidden" name="tableOffset11" value=<%=tabOffset[11]%> />
          <input type="hidden" name="tableOffset12" value=<%=tabOffset[12]%> />
          <input type="hidden" name="tableOffset13" value=<%=tabOffset[13]%> />
          <input type="hidden" name="tableOffset14" value=<%=tabOffset[14]%> />
          <input type="hidden" name="tableOffset15" value=<%=tabOffset[15]%> />
          <input type="hidden" name="tableOffset16" value=<%=tabOffset[16]%> />
          <input type="hidden" name="tableOffset17" value=<%=tabOffset[17]%> />
          <input type="hidden" name="tableOffset18" value=<%=tabOffset[18]%> />
          <input type="hidden" name="tableOffset19" value=<%=tabOffset[19]%> />
        </td>
    </form>
    <form action="analytics_new.jsp" method="GET">
        <tr><td align="center">
        <button type="submit">Analytics Home</button></td></tr>
    </form>
</table>
<%
}
catch(Exception e) { 
    out.println(e.getMessage()); }
finally {
    System.out.println("End query");
    conn.close(); 
   }   
%>
</body>
</html>