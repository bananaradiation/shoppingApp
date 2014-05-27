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
    String category = (String)request.getParameter("category");
    String age = (String)request.getParameter("age");
    String rowPg = (String)request.getParameter("rowPage");
    String colPg = (String)request.getParameter("colPage");
    if (option == null) {
        option = "customers";
    }
    if (state == null) {
        state = "all";
    }
    if (category == null) {
        category = "all";
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
Statement row_stmt, col_stmt, grid_stmt;
ResultSet row_rs=null, col_rs=null, grid_rs=null;

try
{
    try{Class.forName("org.postgresql.Driver");}catch(Exception e){System.out.println("Driver error");}
    String url="jdbc:postgresql://localhost/cse135test123";
    String user="postgres";
    String password="postgres";
    conn = DriverManager.getConnection(url, user, password);
    row_stmt = conn.createStatement();
    col_stmt = conn.createStatement();
    grid_stmt = conn.createStatement();

    //  SQL - customer option
    String cust_end = " group by u.name order by u.name asc limit 20 "+"offset "+(Integer.parseInt(rowPg)-1)*20+";";

    String SQL_cust="select u.name, sum(s.quantity*p.price) as amount from users u, sales s, products p where s.uid=u.id and s.pid=p.id "+cust_end; 
            
    String SQL_cust_age="select u.name, sum(s.quantity*p.price) as amount from users u, sales s, products p where s.uid=u.id and s.pid=p.id and u.age between "+age+ cust_end;
            
    String SQL_cust_state="select u.name, sum(s.quantity*p.price) as amount from users u, sales s, products p where s.uid=u.id and s.pid=p.id and u.state='"+state+"'"+ cust_end;
                    
    String SQL_cust_prod="select u.name, sum(s.quantity*p.price) as amount from users u, sales s, products p, categories c where s.uid=u.id and s.pid=p.id and p.cid=c.id and c.name='"+category+"'"+cust_end;
                    
    String SQL_cust_age_state="select u.name, sum(s.quantity*p.price) as amount from users u, sales s, products p where s.uid=u.id and s.pid=p.id and u.state='"+state+"' and u.age between "+age+ cust_end;
            
    String SQL_cust_age_prod="select u.name, sum(s.quantity*p.price) as amount from users u, sales s, products p, categories c where s.uid=u.id and s.pid=p.id and p.cid=c.id and c.name='"+category+"' and u.age between "+age+ cust_end;
            
    String SQL_cust_state_prod="select u.name, sum(s.quantity*p.price) as amount from users u, sales s, products p, categories c where s.uid=u.id and s.pid=p.id and p.cid=c.id and c.name='"+category+"' and u.state='"+state+"'"+cust_end;
            
    String SQL_cust_age_state_prod="select u.name, sum(s.quantity*p.price) as amount from users u, sales s, products p, categories c where s.uid=u.id and s.pid=p.id and p.cid=c.id and c.name='"+category+"' and u.state='"+state+"'and u.age between "+age+cust_end;
            

    //  SQL - state option
    String state_end=" group by u.state order by u.state asc limit 20 "+"offset "+(Integer.parseInt(rowPg)-1)*20+";";
    String SQL_state="select u.state, sum(s.quantity*p.price) as amount from users u, sales s,  products p where s.uid=u.id and s.pid=p.id "+ state_end;
    String SQL_state_state="select u.state, sum(s.quantity*p.price) as amount from users u, sales s,  products p where s.uid=u.id and s.pid=p.id and u.state='"+state+"'"+ state_end;
    String SQL_state_age="select u.state, sum(s.quantity*p.price) as amount from users u, sales s,  products p where s.uid=u.id and s.pid=p.id and u.age between "+age+ state_end;
    String SQL_state_prod="select u.state, sum(s.quantity*p.price) as amount from users u, sales s, products p, categories c where s.uid=u.id and s.pid=p.id and p.cid=c.id and c.name='"+category+"'"+ state_end;
    String SQL_state_state_age="select u.state, sum(s.quantity*p.price) as amount from users u, sales s,  products p where s.uid=u.id and s.pid=p.id and u.age between "+age+" and u.state='"+state+"'"+ state_end;
    String SQL_state_state_prod="select u.state, sum(s.quantity*p.price) as amount from users u, sales s,  products p, categories c where s.uid=u.id and s.pid=p.id and p.cid=c.id and c.name='"+category+"' and u.state='"+state+"'"+state_end;
    String SQL_state_age_prod="select u.state, sum(s.quantity*p.price) as amount from users u, sales s,  products p, categories c where s.uid=u.id and s.pid=p.id and p.cid=c.id and c.age between "+age+" and u.state='"+state+"'"+state_end;
    String SQL_state_state_age_prod="select u.state, sum(s.quantity*p.price) as amount from users u, sales s,  products p, categories c where s.uid=u.id and s.pid=p.id and p.cid=c.id and c.name='"+category+"' and c.age between "+age+" and u.state='"+state+"'"+state_end;
    
    // SQL - product (col)
    String SQL_prod="select p.id, p.name, sum(s.quantity*p.price) as amount from products p, sales s "+
                 "where s.pid=p.id "+
                 "group by p.name,p.id "+
                 "order by  p.name asc "+
                 "limit 10 "+"offset "+(Integer.parseInt(colPg)-1)*10+";";
    String SQL_prod_cat="select p.id, p.name, sum(s.quantity*p.price) as amount from products p, sales s, categories c "+
                 "where s.pid=p.id and p.cid=c.id and c.name='"+category+"'"+
                 "group by p.name,p.id "+
                 "order by  p.name asc "+
                 "limit 10 "+"offset "+(Integer.parseInt(colPg)-1)*10+";";
                 
    // row options: customers
    startTime = System.currentTimeMillis();
    if(option.equals("customers") || option.equals("")) {
        if (!age.equals("all") && !state.equals("all") && !category.equals("all")) {
            row_rs=row_stmt.executeQuery(SQL_cust_age_state_prod);
        }
        else if (!state.equals("all") && !category.equals("all")) {
            row_rs=row_stmt.executeQuery(SQL_cust_state_prod);
        }
        else if (!age.equals("all") && !category.equals("all")) {
            row_rs=row_stmt.executeQuery(SQL_cust_age_prod);
        }
        else if (!age.equals("all") && !state.equals("all")) {
            row_rs=row_stmt.executeQuery(SQL_cust_age_state);
        }
        else if (!state.equals("all")) {
            row_rs=row_stmt.executeQuery(SQL_cust_state);
        }
        else if (!category.equals("all")) {
            row_rs=row_stmt.executeQuery(SQL_cust_prod);
        }
        else if (!age.equals("all")) {
            row_rs=row_stmt.executeQuery(SQL_cust_age);
        }
        else {
            row_rs=row_stmt.executeQuery(SQL_cust);
        }
    }

    // row option: states
    else if(option.equals("states")) {
        if (!state.equals("all") && !age.equals("all") && !category.equals("all")) {
            row_rs=row_stmt.executeQuery(SQL_state_state_age_prod);
        }
        else if (!age.equals("all") && !category.equals("all")) {
            row_rs=row_stmt.executeQuery(SQL_state_age_prod);
        }
        else if (!state.equals("all") && !category.equals("all")) {
            row_rs=row_stmt.executeQuery(SQL_state_state_prod);
        }
        else if (!state.equals("all") && !age.equals("all")) {
            row_rs=row_stmt.executeQuery(SQL_state_state_age);
        }
        else if (!state.equals("all")) {
            row_rs=row_stmt.executeQuery(SQL_state_state);
        }
        else if (!age.equals("all")) {
            row_rs=row_stmt.executeQuery(SQL_state_age);
        }
        else if (!category.equals("all")) {
            row_rs=row_stmt.executeQuery(SQL_state_prod);
        }
        else {
            row_rs=row_stmt.executeQuery(SQL_state);
        }
    }
    finishTime = System.currentTimeMillis();
    System.out.println("Time for ROW query: " + (finishTime-startTime) + "ms line 248");

    // product query (columns)
    startTime = System.currentTimeMillis();
    if (!category.equals("all")) {
        col_rs=col_stmt.executeQuery(SQL_prod_cat);
    }
    else {
        col_rs=col_stmt.executeQuery(SQL_prod);
    }
    finishTime = System.currentTimeMillis();
    System.out.println("Time for COL query: " + (finishTime-startTime) + "ms line 259");
    int p_id=0;
    String p_name=null;
    float p_amount_price=0;
    while(col_rs.next()) {
        p_id=col_rs.getInt(1);
        p_name=col_rs.getString(2);
        p_amount_price=col_rs.getFloat(3);
        item=new Item();
        item.setId(p_id);
        item.setName(p_name);
        item.setAmount_price(p_amount_price);
        p_list.add(item);
    }

// customer or state query (rows)
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
        <form action="analytics.jsp" method="POST">
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
        ResultSet rsCategory=stmtCategory.executeQuery("SELECT name FROM categories");
        ArrayList<String> categoryDrop = new ArrayList<String>();
        categoryDrop.add("all");
        while (rsCategory.next()) {
            categoryDrop.add(rsCategory.getString("name")); }  %>

        <tr>
            <td>Category:</td>
            <td><select name="category">
                    <option value="<%=category %>"><%=category %></option>
                    <% for (j = 0; j < categoryDrop.size(); j++) { 
               if (!categoryDrop.get(j).equals(category)) { %>
                    <option value="<%= categoryDrop.get(j)%>"><%= categoryDrop.get(j)%></option>
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

for(i=0;i<p_list.size();i++) {
    p_id            =   p_list.get(i).getId();
    p_name          =   p_list.get(i).getName();
    p_amount_price  =   p_list.get(i).getAmount_price();
    out.print("<td> <strong>"+p_name+"<br>("+p_amount_price+")</strong></td>");
} %>
    </tr> <%  

startTime = System.currentTimeMillis();  
for(i=0;i<s_list.size();i++) {
    s_name          =   s_list.get(i).getName();
    s_amount_price  =   s_list.get(i).getAmount_price();
    out.println("<tr  align=\"center\">");
    out.println("<td><strong>"+s_name+" ("+s_amount_price+")</strong></td>"); 

    for(j=0;j<p_list.size();j++) {      
        p_id            =   p_list.get(j).getId();
        p_name          =   p_list.get(j).getName();
        p_amount_price  =   p_list.get(j).getAmount_price();
      
        String SQL_grid_state="select sum(c.quantity*p.price) as amount from users u, products p, sales c "+
                "where c.uid=u.id and c.pid=p.id and u.state='"+s_name+"' and p.id='"+p_id+"' group by u.state, p.name";
        String SQL_grid_cust="select sum(c.quantity*p.price) as amount from users u, products p, sales c "+
                   "where c.uid=u.id and c.pid=p.id and u.name='"+s_name+"' and p.id='"+p_id+"' group by u.state, p.name";
           
        if("customers".equals(option) || "".equals(option)) {
           grid_rs = grid_stmt.executeQuery(SQL_grid_cust);
        }
        else if ("states".equals(option)) {
           grid_rs = grid_stmt.executeQuery(SQL_grid_state); 
        }
        if(grid_rs.next()) {
            amount=grid_rs.getFloat(1);
            out.print("<td><font color='#0000ff'>"+amount+"</font></td>");
        }
        else {
           out.println("<td><font color='#ff0000'>0</font></td>");
        }
    }
    out.println("</tr>");
}
finishTime = System.currentTimeMillis();
System.out.println("Time for GRID query: " + (finishTime-startTime) + "ms line 429"); %>
    <form action="analytics.jsp" method="GET">
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
            </td>
    </form>
    <form action="analytics.jsp" method="GET">
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
        </td>
    </form>
    <form action="analytics.jsp" method="GET">
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
    conn.close(); }   
%>
</body>
</html>