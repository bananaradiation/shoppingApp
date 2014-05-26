import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;

public class DataTest
{
	private Connection conn = null;
	private Statement stmt=null;
	public boolean openConn() throws Exception
	{
	   try{
	    try{Class.forName("org.postgresql.Driver");}catch(Exception e){System.out.println("Driver error");}
	    String url="jdbc:postgresql://localhost/cse135test"; //database name
	    String user="postgres";							 //username
	    String password="postgres";						//password
	    conn=DriverManager.getConnection(url, user, password);
	    return true;
	    }
	   catch(SQLException e)
	   {
	    e.printStackTrace();
	    return false;
	   }
	
	}
	
	public boolean openStatement() throws SQLException
	{
	   stmt=conn.createStatement();
	   return true;
	}
	public void init()throws SQLException
	{
		dropCreateTable("DROP TABLE users CASCADE;","CREATE TABLE users (id SERIAL PRIMARY KEY, name TEXT NOT NULL UNIQUE, role TEXT, age INTEGER,state TEXT);");
		dropCreateTable("DROP TABLE categories CASCADE;","CREATE TABLE categories(id SERIAL PRIMARY KEY,name TEXT NOT NULL UNIQUE, description TEXT);");
		dropCreateTable("DROP TABLE products CASCADE;","CREATE TABLE products (id SERIAL PRIMARY KEY,cid INTEGER REFERENCES categories (id) ON DELETE CASCADE,name TEXT NOT NULL,SKU TEXT NOT NULL UNIQUE,price INTEGER NOT NULL);");
		dropCreateTable("DROP TABLE sales CASCADE;","CREATE TABLE sales (id SERIAL PRIMARY KEY,uid INTEGER REFERENCES users (id) ON DELETE CASCADE,pid INTEGER REFERENCES products (id) ON DELETE CASCADE,quantity INTEGER NOT NULL, price INTEGER NOT NULL);");
		dropCreateTable("DROP TABLE carts CASCADE;","CREATE TABLE carts (id SERIAL PRIMARY KEY,uid INTEGER REFERENCES users (id) ON DELETE CASCADE,pid INTEGER REFERENCES products (id) ON DELETE CASCADE,quantity INTEGER NOT NULL, price INTEGER NOT NULL);");
		
		//tempory tables
//		dropCreateTable("DROP TABLE u_t;","CREATE TABLE u_t (id int);");
//		dropCreateTable("DROP TABLE p_t;","CREATE TABLE p_t (id int);");
//		dropCreateTable("DROP TABLE us_t;","CREATE TABLE us_t (state text);");
//		dropCreateTable("DROP TABLE ps_t;","CREATE TABLE ps_t (id int);");
	}
	public void copy(String usersPath,String categoriesPath,String productsPath, String salesPath) throws SQLException
	{
		System.out.println("==========================================================");
		System.out.println("Inserting users data.....");
		stmt.execute("COPY users(name,role,age,state) FROM '"+usersPath+"' USING DELIMITERS ',';");
		System.out.println("Successfully inserting users data into database");
		System.out.println("Inserting categories data.....");
		stmt.execute("COPY categories (name,description) FROM '"+categoriesPath+"' USING DELIMITERS ',';");
		System.out.println("Successfully inserting categories data into database");
		System.out.println("Inserting products data.....");
		stmt.execute("COPY products(cid,name,SKU,price) FROM '"+productsPath+"' USING DELIMITERS ',';");
		System.out.println("Successfully inserting products data into database");
		System.out.println("Inserting sales data.....");
		stmt.execute("COPY sales(uid,pid,quantity,price) FROM '"+salesPath+"' USING DELIMITERS ',';");
		System.out.println("Successfully inserting sales data into database");
	}
	public boolean dropCreateTable(String sql, String sql2) throws SQLException
	{
		try{
			stmt.execute(sql);
			stmt.execute(sql2);
			return true;
		}catch(SQLException e)
		{
			stmt.execute(sql2);
			return false;
		}
	}
	public void insert(String sql) throws SQLException
	{
		stmt.execute(sql);
	}
	public void insertAll(ArrayList<String> sqls) throws SQLException
	{
		for(int i=0;i<sqls.size();i++)
		{
			stmt.execute(sqls.get(i));
		}
	}
	public ResultSet getQuery(String sql) throws Exception
	{
	   ResultSet rs=null;
	   rs=stmt.executeQuery(sql);
	   return rs;
	}
	public boolean closeConn() throws SQLException
	{
	   conn.close();
	   return true;
	}

}