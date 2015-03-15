--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- Name: anecdote_id_seq; Type: SEQUENCE; Schema: public; Owner: boa
--

CREATE SEQUENCE anecdote_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE anecdote_id_seq OWNER TO boa;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: anecdotes; Type: TABLE; Schema: public; Owner: boa; Tablespace: 
--

CREATE TABLE anecdotes (
    anecdote_id integer NOT NULL,
    ghost_id integer,
    reported boolean NOT NULL,
    feedback_average real NOT NULL,
    n_feedback real NOT NULL,
    synopsis text NOT NULL,
    full_content text,
    latitude real NOT NULL,
    longitude real NOT NULL
);


ALTER TABLE anecdotes OWNER TO boa;

--
-- Name: catch; Type: TABLE; Schema: public; Owner: boa; Tablespace: 
--

CREATE TABLE catch (
    catch_id integer NOT NULL,
    anecdote_id integer,
    user_id integer,
    feedback real,
    catch_date date NOT NULL
);


ALTER TABLE catch OWNER TO boa;

--
-- Name: catch_id_seq; Type: SEQUENCE; Schema: public; Owner: boa
--

CREATE SEQUENCE catch_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE catch_id_seq OWNER TO boa;

--
-- Name: ghost_id_seq; Type: SEQUENCE; Schema: public; Owner: boa
--

CREATE SEQUENCE ghost_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE ghost_id_seq OWNER TO boa;

--
-- Name: ghosts; Type: TABLE; Schema: public; Owner: boa; Tablespace: 
--

CREATE TABLE ghosts (
    ghost_id integer NOT NULL,
    patronymic text NOT NULL,
    image_path text NOT NULL
);


ALTER TABLE ghosts OWNER TO boa;

--
-- Name: user_id_seq; Type: SEQUENCE; Schema: public; Owner: boa
--

CREATE SEQUENCE user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE user_id_seq OWNER TO boa;

--
-- Name: users; Type: TABLE; Schema: public; Owner: boa; Tablespace: 
--

CREATE TABLE users (
    user_id integer NOT NULL,
    pseudo text NOT NULL,
    email text NOT NULL,
    password text NOT NULL
);


ALTER TABLE users OWNER TO boa;

--
-- Name: anecdote_id_seq; Type: SEQUENCE SET; Schema: public; Owner: boa
--

SELECT pg_catalog.setval('anecdote_id_seq', 1, false);


--
-- Data for Name: anecdotes; Type: TABLE DATA; Schema: public; Owner: boa
--

COPY anecdotes (anecdote_id, ghost_id, reported, feedback_average, n_feedback, synopsis, full_content, latitude, longitude) FROM stdin;
3	2	f	0	0	synopsis 3	full content 3	0.00300000003	0.00300000003
1	1	f	3	1	synopsis 1	full content 1	0.00100000005	0.00100000005
2	1	f	0	1	synopsis 2	full content 2	0.00200000009	0.00200000009
\.


--
-- Data for Name: catch; Type: TABLE DATA; Schema: public; Owner: boa
--

COPY catch (catch_id, anecdote_id, user_id, feedback, catch_date) FROM stdin;
1	1	1	3	2015-03-15
2	2	1	0	2015-03-15
\.


--
-- Name: catch_id_seq; Type: SEQUENCE SET; Schema: public; Owner: boa
--

SELECT pg_catalog.setval('catch_id_seq', 1, false);


--
-- Name: ghost_id_seq; Type: SEQUENCE SET; Schema: public; Owner: boa
--

SELECT pg_catalog.setval('ghost_id_seq', 1, false);


--
-- Data for Name: ghosts; Type: TABLE DATA; Schema: public; Owner: boa
--

COPY ghosts (ghost_id, patronymic, image_path) FROM stdin;
1	fantome1	image1
2	fantome2	image2
\.


--
-- Name: user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: boa
--

SELECT pg_catalog.setval('user_id_seq', 4, true);


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: boa
--

COPY users (user_id, pseudo, email, password) FROM stdin;
1	nuki	xavier.vdw@gmai.com	$2y$06$P6XiaBvqYQVcho5WFetPFug/Yuz5R0jHpHfLBd7ZAbGcX92gwtKLe
\.


--
-- Name: anecdotes_pkey; Type: CONSTRAINT; Schema: public; Owner: boa; Tablespace: 
--

ALTER TABLE ONLY anecdotes
    ADD CONSTRAINT anecdotes_pkey PRIMARY KEY (anecdote_id);


--
-- Name: catch_pkey; Type: CONSTRAINT; Schema: public; Owner: boa; Tablespace: 
--

ALTER TABLE ONLY catch
    ADD CONSTRAINT catch_pkey PRIMARY KEY (catch_id);


--
-- Name: ghosts_pkey; Type: CONSTRAINT; Schema: public; Owner: boa; Tablespace: 
--

ALTER TABLE ONLY ghosts
    ADD CONSTRAINT ghosts_pkey PRIMARY KEY (ghost_id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: boa; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- Name: anecdotes_ghost_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: boa
--

ALTER TABLE ONLY anecdotes
    ADD CONSTRAINT anecdotes_ghost_id_fkey FOREIGN KEY (ghost_id) REFERENCES ghosts(ghost_id) ON DELETE CASCADE;


--
-- Name: catch_anecdote_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: boa
--

ALTER TABLE ONLY catch
    ADD CONSTRAINT catch_anecdote_id_fkey FOREIGN KEY (anecdote_id) REFERENCES anecdotes(anecdote_id) ON DELETE CASCADE;


--
-- Name: catch_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: boa
--

ALTER TABLE ONLY catch
    ADD CONSTRAINT catch_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE;


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

