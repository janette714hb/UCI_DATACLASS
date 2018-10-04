-- use database sakila
USE sakila;

-- 1a. Display first and last name of all actors in table actor
Select * FROM actor;

-- 1b. Display the first and lasdt name of each actor in a single column in upper case letters. Name the column Actor name

SELECT concat(first_name," ", last_name) AS Actor_Name
FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?

Select * from actor where first_name = "Joe";

-- 2b. Find all actors whose last name contain the letters GEN

SELECT last_name
FROM actor
WHERE last_name LIKE '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:

SELECT last_name, first_name
From actor
Where last_name LIKE '%LI%'
ORDER BY last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China

SELECT country_id, country
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. 
	-- You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB 
	-- (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
	-- BLOB (Binary Large Object) is a large object data type in the database system. https://stackoverflow.com/questions/5414551/what-is-it-exactly-a-blob-in-a-dbms-context
    
ALTER TABLE actor
ADD COLUMN description BLOB;

-- Question 3b Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER TABLE actor
DROP COLUMN description;

-- 4a. List the last names of actors, as well as how many actors have that last name.

SELECT COUNT(last_name) as 'Count', last_name as 'actor last name'
FROM actor
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors

SELECT COUNT(last_name) as 'Count', last_name as 'actor last name'
FROM actor
GROUP BY last_name
HAVING COUNT(last_name) >=2;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.

SET SQL_SAFE_UPDATES = 0;

UPDATE actor
SET first_name = 'Harpo'
WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! 
-- In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.

SET SQL_SAFE_UPDATES = 0;

UPDATE actor
SET first_name = 'GROUCHO'
WHERE first_name = 'HARPO' AND last_name = 'WILLIAMS';

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it? Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html

-- SHOW CREATE TABLE address

-- CREATE TABLE `address` (
--   `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
--   `address` varchar(50) NOT NULL,
--   `address2` varchar(50) DEFAULT NULL,
--   `district` varchar(20) NOT NULL,
--   `city_id` smallint(5) unsigned NOT NULL,
--   `postal_code` varchar(10) DEFAULT NULL,
--   `phone` varchar(20) NOT NULL,
--   `location` geometry NOT NULL,
--   `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
--   PRIMARY KEY (`address_id`),

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:

SELECT first_name, last_name, staff_id, address
FROM staff s
INNER JOIN address a
ON s.address_id = a.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.

SELECT first_name, last_name, SUM(amount) as 'Sales'
FROM staff s
INNER JOIN payment p
ON s.staff_id = p.staff_id
group by s.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.

Use sakila;
SELECT title, count(actor_id) as 'actor count'
FROM film f
INNER JOIN film_actor fa
ON f.film_id = fa.film_id
group by f.film_id ASC;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?

SELECT title, COUNT(inventory_id)
FROM film f
INNER JOIN inventory i
ON f.film_id = i.film_id
WHERE title = "Hunchback Impossible";

-- How many versions of the Hunchback of Notre Dame exist (a real movie title)

SELECT title, COUNT(inventory_id)
FROM film f
INNER JOIN inventory i
ON f.film_id = i.film_id
WHERE title = "Hunchback of Notre Dame";

-- Still 0 :-)

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:

SELECT first_name, last_name, SUM(amount)
FROM customer c
INNER JOIN payment p
ON c.customer_id = p.customer_id
group by c.last_name ASC;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
	-- As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
	-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English. % wildcard for rest of text string

SELECT title FROM film
WHERE language_id in
	(SELECT language_id 
	FROM language
	WHERE name = "English" )
	AND (title LIKE "K%") OR (title LIKE "Q%");

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.

SELECT last_name, first_name
FROM actor
WHERE actor_id in
	(SELECT actor_id FROM film_actor
	WHERE film_id in 
		(SELECT film_id FROM film
		WHERE title = "Alone Trip"));
        
-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 
	-- Use joins to retrieve this information.

SELECT country, last_name, first_name, email
FROM country c
LEFT JOIN customer cu
ON c.country_id = cu.customer_id
WHERE country = 'Canada';
    
-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.

Select title, rating
from film
where rating = 'g';

-- 7e. Display the most frequently rented movies in descending order.

SELECT title, count(return_date) 'number of rentals'
from inventory i
inner join rental r
on i.inventory_id = r.inventory_id
inner join film f
on f.film_id = i.film_id
group by i.film_id
order by count(return_date) DESC;

 -- 7f. Write a query to display how much business, in dollars, each store brought in.
 
SELECT store_id, sum(amount) as 'Store Sales'
from staff s
inner join payment p
on s.staff_id = p.staff_id
group by store_id
order by sum(amount) DESC;

-- 7g. Write a query to display for each store its store ID, city, and country.

Select store_id, city, country
from store s
inner join address a
on s.address_id = a.address_id
inner join city c
on c.city_id = a.city_id
inner join country co
on c.country_id = co.country_id;

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category.name, film_category film_id, inventory store_id, payment amount, and rental.)

SELECT name, SUM(p.amount)
FROM category c
INNER JOIN film_category fc
INNER JOIN inventory i
ON i.film_id = fc.film_id
INNER JOIN rental r
ON r.inventory_id = i.inventory_id
INNER JOIN payment p
GROUP BY name
Limit 5;

-- Edit → Preferences → SQL Editor → DBMS connection read time out (in seconds): 600; https://stackoverflow.com/questions/10563619/error-code-2013-lost-connection-to-mysql-server-during-query

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. 
-- If you haven't solved 7h, you can substitute another query to create a view. https://www.w3schools.com/sql/sql_view.asp

CREATE VIEW top_grossing_by_category as

SELECT name, SUM(p.amount)
FROM category c
INNER JOIN film_category fc
INNER JOIN inventory i
ON i.film_id = fc.film_id
INNER JOIN rental r
ON r.inventory_id = i.inventory_id
INNER JOIN payment p
GROUP BY name
Limit 5;

-- 8b. How would you display the view that you created in 8a?

Select * From top_grossing_by_category;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.

DROP VIEW top_grossing_by_category;