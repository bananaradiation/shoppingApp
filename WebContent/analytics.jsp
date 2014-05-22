<%@ page contentType="text/html; charset=utf-8" language="java" import="java.sql.*" import="database.*"   import="java.util.*" errorPage="" %>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>CSE135</title>
<script type="text/javascript" src="js/js.js" language="javascript"></script>
</head>
<body>
<%

String option=null, state=null, category=null, age=null;
try { option = request.getParameter("option");} catch(Exception e){option = "";}
try { state = request.getParameter("state");} catch(Exception e){state = "";}
try { category = request.getParameter("category");} catch(Exception e){category = "";}
try { age = request.getParameter("age");} catch(Exception e){age = "";}  

String stateList[] = {"Alabama","Alaska","Arizona","Arkansas",
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
Statement stmt,stmt_2,stmt_3;
ResultSet rs=null,rs_2=null,rs_3=null;
String SQL=null;
try
{
    try{Class.forName("org.postgresql.Driver");}catch(Exception e){System.out.println("Driver error");}
    String url="jdbc:postgresql://localhost/cse135";
    String user="postgres";
    String password="postgres";
    conn =DriverManager.getConnection(url, user, password);
    stmt =conn.createStatement();
    stmt_2 =conn.createStatement();
    stmt_3 =conn.createStatement();
    
    String SQL_prod_all="select p.id, p.name, sum(s.quantity*p.price) as amount from products p, sales s "+
         "where s.pid=p.id "+
         "group by p.name,p.id "+
         "order by p.name asc "+
         "limit 10;";    
    String SQL_prod_cat="select p.id, p.name, sum(s.quantity*p.price) as amount from products p, sales s, categories c "+
             "where s.pid=p.id and c.id=p.cid and c.name='"+category+"'"+
             " group by p.name,p.id "+
             "order by p.name asc "+
             "limit 10;";         
         
    String SQL_cust="select u.name, sum(s.quantity*p.price) as amount from users u, sales s, products p "+
            "where s.uid=u.id and s.pid=p.id "+ 
            "group by u.name "+ 
            "order by u.name asc "+
            "limit 20;";    
    String SQL_age_state="select u.name, sum(s.quantity*p.price) as amount from users u, sales s, products p "+
            "where s.uid=u.id and s.pid=p.id and u.state='"+state+"' and u.age between "+age+ 
            " group by u.name "+ 
            "order by u.name asc "+
            "limit 20;";
    String SQL_cust_age="select  u.name, sum(s.quantity*p.price) as amount from users u, sales s, products p "+
            "where s.uid=u.id and s.pid=p.id and u.age between "+age+ 
            " group by u.name "+ 
            "order by u.name asc "+
            "limit 20;";    
    String SQL_cust_state="select  u.name, sum(s.quantity*p.price) as amount from users u, sales s, products p "+
            "where s.uid=u.id and s.pid=p.id and u.state='"+state+"'"+ 
            " group by u.name "+ 
            "order by u.name asc "+
            "limit 20;";

    String SQL_state="select  u.state, sum(s.quantity*p.price) as amount from users u, sales s,  products p "+
                  "where s.uid=u.id and s.pid=p.id "+ 
                  "group by u.state "+ 
                  "order by u.state asc "+
                  "limit 20;";
    
//     product category filter
    if (category.equals("all")) {
    	rs = stmt.executeQuery(SQL_prod_all);
    }
    else {
    	rs = stmt.executeQuery(SQL_prod_cat);
    }   
    
    int p_id=0;
    String p_name=null;
    float p_amount_price=0;
    while(rs.next()) {
        p_id=rs.getInt(1);
        p_name=rs.getString(2);
        p_amount_price=rs.getFloat(3);
        item=new Item();
        item.setId(p_id);
        item.setName(p_name);
        item.setAmount_price(p_amount_price);
        p_list.add(item);
    
    }
    
//     row option
    if(option.equals("customers") || option.equals("")) {
//     	filter state and age
    	if (!age.equals("all") && !state.equals("all")) {
    		rs_2=stmt_2.executeQuery(SQL_age_state);
    	}
    	else if (!age.equals("all")) {
    		rs_2=stmt_2.executeQuery(SQL_cust_age);
    	}
    	else if (!state.equals("all")) {
    		rs_2=stmt_2.executeQuery(SQL_cust_state);
    	}
    	else {
    		rs_2=stmt_2.executeQuery(SQL_cust);
    	}
    }
    else if(option.equals("states")) {
	    rs_2=stmt_2.executeQuery(SQL_state);
    }
    String s_name=null;
    float s_amount_price=0;
    while(rs_2.next()) {
	    s_name=rs_2.getString(1);
	    s_amount_price=rs_2.getFloat(2);
	    item=new Item();
	    item.setName(s_name);
	    item.setAmount_price(s_amount_price);
	    s_list.add(item);
    }
    
    int i=0,j=0;
    String SQL_3="";  
    float amount=0; %>

<form action="analytics.jsp" method="POST">
    Sort rows by: 
    <select name="option">
        <option value="customers">Customers</option>
        <option value="states">States</option>
    </select><p/>
    Filter sales by:
    <select name="state">
        <option value="all">All States</option> <% 
        for (i = 0; i < 50; i++) { %>
        <option value="<%=stateList[i]%>"><%=stateList[i]%></option> <% } %>
    </select>    <%
    
    Statement stmtCategory = conn.createStatement();
    ResultSet rsCategory=stmtCategory.executeQuery("SELECT name FROM categories");
    ArrayList<String> categoryDrop = new ArrayList<String>();
    while (rsCategory.next()) {
        categoryDrop.add(rsCategory.getString("name")); } %>
    
    <select name="category">
        <option value="all">All Categories</option>
        <% for (j = 0; j < categoryDrop.size(); j++) { %>
        <option value="<%= categoryDrop.get(j)%>"><%= categoryDrop.get(j)%></option> <% } %>    
    </select>
    <select name="age">
        <option value="all">All Ages</option>
        <option value="12 and 18">12-18</option>
        <option value="19 and 45">19-45</option>
        <option value="46 and 65">46-65</option>
        <option value="65 and 1000">65+</option>
    </select>
    <button type="submit">Run Query</button>
</form>
<%=option %> <br>
<%=category %> <br>
<%=age %> <br>
<%=state %>  <br>
    <table align="center" width="98%" border="1">
        <tr align="center">
            <td><strong><font color="#FF0000">STATE</font></strong></td>
<%  
    for(i=0;i<p_list.size();i++) {
        p_id            =   p_list.get(i).getId();
        p_name          =   p_list.get(i).getName();
        p_amount_price  =   p_list.get(i).getAmount_price();
        out.print("<td> <strong>"+p_name+"<br>["+p_amount_price+"]</strong></td>");
    }
%>
        </tr>
<%  
    for(i=0;i<s_list.size();i++) {
        s_name          =   s_list.get(i).getName();
        s_amount_price  =   s_list.get(i).getAmount_price();
        out.println("<tr  align=\"center\">");
        out.println("<td><strong>"+s_name+"["+s_amount_price+"]</strong></td>");
        for(j=0;j<p_list.size();j++) {
            p_id            =   p_list.get(j).getId();
            p_name          =   p_list.get(j).getName();
            p_amount_price  =   p_list.get(j).getAmount_price();
            
            String SQL_state2="select sum(c.quantity*p.price) as amount from users u, products p, sales c "+
                 "where c.uid=u.id and c.pid=p.id and u.state='"+s_name+"' and p.id='"+p_id+"' group by u.state, p.name";
            String SQL_cust2="select sum(c.quantity*p.price) as amount from users u, products p, sales c "+
                    "where c.uid=u.id and c.pid=p.id and u.name='"+s_name+"' and p.id='"+p_id+"' group by u.state, p.name";

            if("customers".equals(option) || "".equals(option)) {
            	rs_3=stmt_3.executeQuery(SQL_cust2);
            }
            else if ("states".equals(option)) {
                rs_3=stmt_3.executeQuery(SQL_state2);	
            }
            if(rs_3.next()) {
                amount=rs_3.getFloat(1);
                out.print("<td><font color='#0000ff'>"+amount+"</font></td>");
            }
            else {
               out.println("<td><font color='#ff0000'>0</font></td>");
            }

        }
        out.println("</tr>");
    }
    
    session.setAttribute("TOP_10_Products",p_list);
%>
        <form action="analytics.jsp" method="POST">
        <tr> <% if (option.equals("states")) { %>
        <td colspan="10"><input type="button" value="Next 20 States"> <% } else { %>
        <td colspan="10"><input type="button" value="Next 20 Customers"> <% } %>
        <input type="button" value="Next 10 Products"></tr>
        </form>
    </table>
<%
}
catch(Exception e) { 
	out.println(e.getMessage()); }
finally {
	conn.close(); }   
%>  
</body>
</html>