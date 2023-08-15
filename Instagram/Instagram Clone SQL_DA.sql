/*인스타그램 클론 데이터를 활용한 사용자 데이터 분석 프로젝트*/

/*SQL SKILLS: joins, date manipulation, regular expressions, views, stored procedures, aggregate functions, string manipulation*/
 
-- --------------------------------------------------------------------------------------------------------------
use instagram;
/*Ques.1 : 인스타그램의 가장 먼저 가입한 회원 10명은 누구인가?*/

SELECT 
    *
FROM
    instagram.users
ORDER BY created_at asc
LIMIT 10;
-- --------------------------------------------------------------------------------------------------------------

/*Ques.2 : 인스타그램의 총 회원수는 몇명인가*/

SELECT 
    COUNT(*) AS 'Total Registration'
FROM
    instagram.users;
-- --------------------------------------------------------------------------------------------------------------

/*Ques.3 : 가장 많은 회원이 등록한 요일은 언제인가?*/

CREATE VIEW vwtotalregistrations AS
    SELECT 
        DATE_FORMAT(created_at, '%W') AS 'day of the week',
        COUNT(*) AS 'total number of registration'
    FROM
        ig_clone.users
    GROUP BY 1
    ORDER BY 2 DESC;
    
SELECT 
    *
FROM
    vwtotalregistrations;
-- --------------------------------------------------------------------------------------------------------------

/*Ques.4 : 사진을 한번도 게시한 적이 없는 회원은 누구인가?*/

SELECT 
    u.username
FROM
    ig_clone.users u
        LEFT JOIN
    ig_clone.photos p ON p.user_id = u.id
WHERE
    p.id IS NULL;
-- --------------------------------------------------------------------------------------------------------------

/*Ques.5 : 가장 많은 좋아요를 받은 사진은 무엇인가?*/
	
SELECT 
     u.username, p.image_url, COUNT(*) AS total
FROM
    ig_clone.photos p
        INNER JOIN
    ig_clone.likes l ON l.photo_id = p.id
        INNER JOIN
    ig_clone.users u ON p.user_id = u.id
GROUP BY p.id
ORDER BY total DESC
LIMIT 1;

-- --------------------------------------------------------------------------------------------------------------

/*Ques.6 : 가장 많이 활성화된 회원이 게시한 사진 수는 몇개인가?*/

SELECT 
	u.username AS 'Username',
    COUNT(p.image_url) AS 'Number of Posts'
FROM
    ig_clone.users u
        JOIN
    ig_clone.photos p ON u.id = p.user_id
GROUP BY u.id
ORDER BY 2 DESC
LIMIT 5;
-- --------------------------------------------------------------------------------------------------------------

/*Ques.7 : 게시물의 총 개수는 몇 개 인가?*/

SELECT 
    SUM(user_posts.total_posts_per_user) AS 'Total Posts by Users'
FROM
    (SELECT 
        u.username, COUNT(p.image_url) AS total_posts_per_user
    FROM
        ig_clone.users u
    JOIN ig_clone.photos p ON u.id = p.user_id
    GROUP BY u.id) AS user_posts;
-- --------------------------------------------------------------------------------------------------------------

/*Ques.8 : 전체 회원 중 게시물을 올린 회원은 몇 명 인가?*/

SELECT 
    COUNT(DISTINCT (u.id)) AS total_number_of_users_with_posts
FROM
    ig_clone.users u
        JOIN
    ig_clone.photos p ON u.id = p.user_id;
-- --------------------------------------------------------------------------------------------------------------

/*Ques.9 : 회원 아이디 뒤에 숫자가 있는 회원의 이름은 무엇인가?*/

SELECT 
    id, username
FROM
    ig_clone.users
WHERE
    username REGEXP '[$0-9]';
-- --------------------------------------------------------------------------------------------------------------

/*Ques.10 : 문자로 끝나는 사용자 이름은 무엇인가?*/

SELECT 
    id, username
FROM
    ig_clone.users
WHERE
    username NOT REGEXP '[$0-9]';
-- --------------------------------------------------------------------------------------------------------------

/*Ques.11 : 아이디가 A로 시작하는 회원 수는 몇 명 인가?*/

SELECT 
    count(id)
FROM
    ig_clone.users
WHERE
    username REGEXP '^[A]';
-- --------------------------------------------------------------------------------------------------------------

/*Ques.12 : 가장 자주 나오는 태그는 무엇인가?*/

SELECT 
    t.tag_name, COUNT(tag_name) AS seen_used
FROM
    ig_clone.tags t
        JOIN
    ig_clone.photo_tags pt ON t.id = pt.tag_id
GROUP BY t.id
ORDER BY seen_used DESC
LIMIT 10;
-- --------------------------------------------------------------------------------------------------------------

/*Ques.13 : 좋아요별 가장 인기 있는 태그는 무엇인가?*/

SELECT 
    t.tag_name AS 'Tag Name',
    COUNT(l.photo_id) AS 'Number of Likes'
FROM
    ig_clone.photo_tags pt
        JOIN
    ig_clone.likes l ON l.photo_id = pt.photo_id
        JOIN
    ig_clone.tags t ON pt.tag_id = t.id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;
-- --------------------------------------------------------------------------------------------------------------

/*Ques.14 : 모든 사진이 좋아요를 받는 사용자는?*/

SELECT 
    u.id, u.username, COUNT(l.user_id) AS total_likes_by_user
FROM
    ig_clone.users u
        JOIN
    ig_clone.likes l ON u.id = l.user_id
GROUP BY u.id
HAVING total_likes_by_user = (SELECT 
        COUNT(*)
    FROM
        ig_clone.photos);
-- --------------------------------------------------------------------------------------------------------------

/*Ques.15 : 댓글이 없는 회원은 몇 명 인가?*/

SELECT 
    COUNT(*) AS total_number_of_users_without_comments
FROM
    (SELECT 
        u.username, c.comment_text
    FROM
        ig_clone.users u
    LEFT JOIN ig_clone.comments c ON u.id = c.user_id
    GROUP BY u.id , c.comment_text
    HAVING comment_text IS NULL) AS users;
-- --------------------------------------------------------------------------------------------------------------

/*Ques.16 : 게시글에 댓글을 달지 않는 회원/모든 게시글에 좋아요를 누르는 회원을 비교한 백분율은?*/

SELECT 
    tableA.total_A AS 'Number Of Users who never commented',
    (tableA.total_A / (SELECT 
            COUNT(*)
        FROM
            ig_clone.users u)) * 100 AS '%',
    tableB.total_B AS 'Number of Users who likes every photos',
    (tableB.total_B / (SELECT 
            COUNT(*)
        FROM
            ig_clone.users u)) * 100 AS '%'
FROM
    (SELECT 
        COUNT(*) AS total_A
    FROM
        (SELECT 
        u.username, c.comment_text
    FROM
        ig_clone.users u
    LEFT JOIN ig_clone.comments c ON u.id = c.user_id
    GROUP BY u.id , c.comment_text
    HAVING comment_text IS NULL) AS total_number_of_users_without_comments) AS tableA
        JOIN
    (SELECT 
        COUNT(*) AS total_B
    FROM
        (SELECT 
        u.id, u.username, COUNT(u.id) AS total_likes_by_user
    FROM
        ig_clone.users u
    JOIN ig_clone.likes l ON u.id = l.user_id
    GROUP BY u.id , u.username
    HAVING total_likes_by_user = (SELECT 
            COUNT(*)
        FROM
            ig_clone.photos p)) AS total_number_users_likes_every_photos) AS tableB;
-- --------------------------------------------------------------------------------------------------------------

/*Ques.17 : 플랫폼에 게시된 사진의 URL 정리하기*/

SELECT 
    SUBSTRING(image_url,
        LOCATE('/', image_url) + 2,
        LENGTH(image_url) - LOCATE('/', image_url)) AS IMAGE_URL
FROM
    ig_clone.photos;
-- --------------------------------------------------------------------------------------------------------------

/*Ques.18 : 플랫폼에서의 평균 시간은 얼마인가?*/

SELECT 
    ROUND(AVG(DATEDIFF(CURRENT_TIMESTAMP, created_at)/360), 2) as Total_Years_on_Platform
FROM
    ig_clone.users;
-- --------------------------------------------------------------------------------------------------------------

/*저장소 생성 */

/*Ques.1 : 가장 유명한 해시테그 리스트 데이터셋 생성*/

CREATE PROCEDURE `spPopularTags`()
BEGIN
SELECT 
    t.tag_name, COUNT(tag_name) AS 'HashtagCounts'
FROM
    ig_clone.tags t
        JOIN
    ig_clone.photo_tags pt ON t.id = pt.tag_id
GROUP BY t.id , 1
ORDER BY 2 DESC; 
END //

CALL `ig_clone`.`spPopularTags`();
-- --------------------------------------------------------------------------------------------------------------

/*Ques.2 : 플랫폼에 한 번 이상 참여한 회원 데이터셋 생성*/

CREATE PROCEDURE `spEngagedUser`()
BEGIN
SELECT DISTINCT
    username
FROM
    ig_clone.users u
        INNER JOIN
    ig_clone.photos p ON p.user_id = u.id
        INNER JOIN
    ig_clone.likes l ON l.user_id = p.user_id
WHERE
    p.id IS NOT NULL
        OR l.user_id IS NOT NULL;
END //

CALL `ig_clone`.`spEngagedUser`();
-- --------------------------------------------------------------------------------------------------------------

/*Ques.3 : 플랫폼에 있는 회원의 총 댓글 수 데이터셋 생성*/

CREATE PROCEDURE `spUserComments`()
BEGIN
SELECT 
COUNT(*)  as 'Total Number of Comments'
FROM (
    SELECT 
        c.user_id, u.username
        FROM ig_clone.users u
	JOIN ig_clone.comments c ON u.id = c.user_idusers
    WHERE
        c.comment_text IS NOT NULL
    GROUP BY u.username , c.user_id) as Table1;
END //

CALL `ig_clone`.`spUserComments`();
-- --------------------------------------------------------------------------------------------------------------

/*Ques.4 : 특정 회원이 작성한 이름, 이미지, 태그, 주석 데이터셋 생성*/

CREATE PROCEDURE `spUserInfo`(IN userid INT(11))
BEGIN
SELECT 
    u.id, u.username, p.image_url, c.comment_text, t.tag_name
FROM
    ig_clone.users u
        INNER JOIN
    ig_clone.photos p ON p.user_id = u.id
        INNER JOIN
    ig_clone.comments c ON c.user_id = u.id
        INNER JOIN
    ig_clone.photo_tags pt ON pt.photo_id = p.id
        INNER JOIN
    ig_clone.tags t ON t.id = pt.tag_id
where u.id = userid;
END //

CALL `ig_clone`.`spUserInfo`(2);
-- --------------------------------------------------------------------------------------------------------------
