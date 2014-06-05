create index p_cididx on products(cid);
create index s_uididx on sales(uid);
create index s_pididx on sales(pid);
create index c_uididx on carts(uid);
create index c_pididx on carts(pid);

CREATE TABLE customerView (
	uid 	INTEGER PRIMARY KEY, 
	state 	TEXT NOT NULL, 
	amt 	INTEGER
);
INSERT INTO customerView(UID, STATE, AMT)
(SELECT sales.uid as UID, users.state as STATE, SUM(sales.quantity*sales.price) as AMT
FROM sales, users
WHERE sales.uid=users.id
GROUP BY sales.uid, users.state);
create index stateidx on customerView(state);

CREATE TABLE productView (
	id 		SERIAL PRIMARY KEY,
	pid		INTEGER NOT NULL,
	uid		INTEGER NOT NULL,
	cid		INTEGER NOT NULL,
	amt     INTEGER
);
INSERT INTO productView(PID, UID, CID, AMT)
(SELECT sales.pid AS PID, sales.uid AS UID, products.cid AS CID, SUM(sales.quantity*sales.price) AS AMT
FROM sales, products
WHERE sales.pid=products.id
GROUP BY sales.pid, sales.uid, products.cid
);
create index pididx on productView(pid);
create index uid on productView(uid);
create index cid on productView(cid);
	
CREATE TABLE stateView(
	id		SERIAL PRIMARY KEY,
	state   TEXT NOT NULL,
	cid     INTEGER NOT NULL,
	amt 	INTEGER 
);
INSERT INTO stateView(STATE,CID,AMT)
(SELECT users.state AS STATE, products.cid AS CID, SUM(sales.quantity*sales.price) AS AMT
FROM users, sales, products
WHERE users.id=sales.uid AND products.id=sales.pid
GROUP BY products.cid, users.state
);
create index cididx on stateView(cid);

-- super fast no filter column header generatation
drop table topP; 
create table topP as 
(SELECT prod.name, prod.id, prod.total 
FROM 
(SELECT name, products.id, sum(amt) AS total 
FROM productView, products 
WHERE productView.pid=products.id 
GROUP BY products.id, products.name) AS prod 
ORDER BY total DESC LIMIT 10);	


-- grid (filters already done on row/cols)
-- customer
select amt
from productView, products, users 
where productView.pid=products.id 
and productView.pid=? 
and productView.uid=? 
group by products.name, amt

-- state
select products.name, amt
from productView, products, users 
where productView.pid=products.id 
and productView.pid=? 
and productView.uid=users.id 
and users.state=? 
group by products.name, amt


-- product col, no filter
SELECT prod.name, prod.id, prod.total
FROM (SELECT name, products.id, SUM(amt) AS total
FROM productView, products
WHERE productView.pid=products.id
GROUP BY products.id, products.name) AS prod
ORDER BY total DESC
LIMIT 10;

-- product col, state filter
SELECT prod.name, prod.id, prod.total
FROM (SELECT products.name, products.id, SUM(amt) AS total
FROM productView, products, users
WHERE productView.pid=products.id AND productView.uid=users.id AND users.state='"+state+"'
GROUP BY products.id, products.name) AS prod
ORDER BY total DESC
LIMIT 10;

-- product col, category filter
SELECT prod.name, prod.id, prod.total
FROM (SELECT products.name, products.id, SUM(amt) AS total
FROM productView, products
WHERE productView.pid=products.id AND productView.cid = '"+category+"'
GROUP BY products.id, products.name) AS prod
ORDER BY total DESC
LIMIT 10;

-- product col, state&category filter
SELECT name, prod.id, total
FROM (SELECT products.name, products.id, SUM(amt) AS total
FROM productView, products, users
WHERE productView.pid=products.id AND productView.uid=users.id AND productView.cid = '"+category+"' AND users.state='"+state+"'
GROUP BY products.id, products.name) AS prod
ORDER BY total DESC
LIMIT 10;

-- customer row, no filter
SELECT users.name, users.id, SUM(amt)
FROM customerView, users
WHERE customerView.uid=users.id
GROUP BY users.name,users.id, amt
ORDER BY amt DESC
LIMIT 20;

-- customer row, state filter
SELECT users.name, users.id, SUM(amt)
FROM customerView, users
WHERE customerView.uid=users.id AND users.state='"+state+"'
GROUP BY users.name, users.id, amt
ORDER BY amt DESC
LIMIT 20;

-- customer row, category filter
SELECT name, id, total
FROM (SELECT users.name, users.id, SUM(amt) AS total
FROM productView, users
WHERE productView.uid=users.id AND productView.cid = '"+category+"'
GROUP BY users.id, users.name) AS foo
ORDER BY total DESC
LIMIT 20;

-- customer row, state&category filter
SELECT name, id, total
FROM (SELECT users.name, users.id, SUM(amt) AS total
FROM productView, users
WHERE productView.uid=users.id AND productView.cid = '+"category"+' AND users.state='+"state"+'
GROUP BY users.id, users.name) AS foo
ORDER BY total DESC
LIMIT 20;

-- state row, no filter
SELECT state, sum(amt) 
FROM stateView
GROUP BY state
ORDER BY sum(amt) DESC
LIMIT 20;

-- state row, state filter
SELECT state, sum(amt) 
FROM stateView
WHERE state = '+"state"+'
GROUP BY state;

-- state row, category filter
SELECT state, sum(amt)
FROM stateView
WHERE cid = '+"category"+'
GROUP BY cid, state
ORDER BY sum(amt) DESC
LIMIT 20;

-- state row, state & category filter
SELECT state, sum(amt)
FROM stateView
WHERE cid = '+"category"+' AND state = '+"state"+'
GROUP BY cid, state
ORDER BY sum(amt) DESC
LIMIT 20