--
-- PostgreSQL database dump
--

-- Dumped from database version 17.4 (Debian 17.4-1.pgdg120+2)
-- Dumped by pg_dump version 17.4 (Debian 17.4-1.pgdg120+2)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: groups; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.groups (
    id uuid NOT NULL,
    name character varying(255) NOT NULL
);


ALTER TABLE public.groups OWNER TO postgres;

--
-- Name: lab_files; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.lab_files (
    id uuid NOT NULL,
    lab_id uuid NOT NULL,
    file_name character varying(255) NOT NULL,
    file_path character varying(255) NOT NULL
);


ALTER TABLE public.lab_files OWNER TO postgres;

--
-- Name: lab_groups; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.lab_groups (
    lab_id uuid NOT NULL,
    group_id uuid NOT NULL
);


ALTER TABLE public.lab_groups OWNER TO postgres;

--
-- Name: lab_submission_files; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.lab_submission_files (
    id uuid NOT NULL,
    lab_submission_id uuid NOT NULL,
    file_name character varying(255) NOT NULL,
    file_path character varying(255) NOT NULL
);


ALTER TABLE public.lab_submission_files OWNER TO postgres;

--
-- Name: lab_submissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.lab_submissions (
    id uuid NOT NULL,
    lab_id uuid NOT NULL,
    student_id uuid NOT NULL,
    grade integer,
    submitted_at timestamp without time zone
);


ALTER TABLE public.lab_submissions OWNER TO postgres;

--
-- Name: labs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.labs (
    id uuid NOT NULL,
    lecturer_id uuid NOT NULL,
    subject_id uuid NOT NULL,
    title character varying(255) NOT NULL,
    description text,
    created timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.labs OWNER TO postgres;

--
-- Name: lecturer_groups; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.lecturer_groups (
    lecturer_id uuid NOT NULL,
    group_id uuid NOT NULL
);


ALTER TABLE public.lecturer_groups OWNER TO postgres;

--
-- Name: lecturer_subjects; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.lecturer_subjects (
    lecturer_id uuid NOT NULL,
    subject_id uuid NOT NULL
);


ALTER TABLE public.lecturer_subjects OWNER TO postgres;

--
-- Name: lecturers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.lecturers (
    user_id uuid NOT NULL,
    first_name character varying(255) NOT NULL,
    middle_name character varying(255),
    last_name character varying(255) NOT NULL
);


ALTER TABLE public.lecturers OWNER TO postgres;

--
-- Name: students; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.students (
    user_id uuid NOT NULL,
    first_name character varying(255) NOT NULL,
    middle_name character varying(255),
    last_name character varying(255) NOT NULL,
    group_id uuid
);


ALTER TABLE public.students OWNER TO postgres;

--
-- Name: subjects; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.subjects (
    id uuid NOT NULL,
    name character varying(255) NOT NULL
);


ALTER TABLE public.subjects OWNER TO postgres;

--
-- Name: temp_tokens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.temp_tokens (
    user_id uuid NOT NULL,
    temp_token text NOT NULL,
    code character varying(6) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    expires_at timestamp without time zone NOT NULL
);


ALTER TABLE public.temp_tokens OWNER TO postgres;

--
-- Name: token; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.token (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    refresh_token text NOT NULL,
    ip_address inet NOT NULL,
    user_agent text NOT NULL,
    unique_id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    expires_at timestamp without time zone NOT NULL,
    is_revoked boolean DEFAULT false NOT NULL
);


ALTER TABLE public.token OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id uuid NOT NULL,
    email character varying(255) NOT NULL,
    password character varying(255) NOT NULL,
    role character varying(20) NOT NULL,
    CONSTRAINT users_role_check CHECK (((role)::text = ANY ((ARRAY['admin'::character varying, 'lecturer'::character varying, 'student'::character varying])::text[])))
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Data for Name: groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.groups (id, name) FROM stdin;
b99c24f9-8141-400c-8c38-cdb37d3daf5c	ПО1-21
b28abc04-b83c-4522-97b3-b2c474c0ae08	ПО2-21
bb8bd1de-f50e-49b0-b984-c2e7066e0436	АС-21
\.


--
-- Data for Name: lab_files; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.lab_files (id, lab_id, file_name, file_path) FROM stdin;
\.


--
-- Data for Name: lab_groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.lab_groups (lab_id, group_id) FROM stdin;
\.


--
-- Data for Name: lab_submission_files; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.lab_submission_files (id, lab_submission_id, file_name, file_path) FROM stdin;
\.


--
-- Data for Name: lab_submissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.lab_submissions (id, lab_id, student_id, grade, submitted_at) FROM stdin;
\.


--
-- Data for Name: labs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.labs (id, lecturer_id, subject_id, title, description, created) FROM stdin;
\.


--
-- Data for Name: lecturer_groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.lecturer_groups (lecturer_id, group_id) FROM stdin;
\.


--
-- Data for Name: lecturer_subjects; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.lecturer_subjects (lecturer_id, subject_id) FROM stdin;
\.


--
-- Data for Name: lecturers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.lecturers (user_id, first_name, middle_name, last_name) FROM stdin;
101008b8-9641-4428-bcd0-367434f16591	ИмяX	ОтчествоX	ФамилияX
\.


--
-- Data for Name: students; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.students (user_id, first_name, middle_name, last_name, group_id) FROM stdin;
f489280e-6e51-44ff-9443-f3a053c04f78	Имя1	Отчество1	Фамилия1	b99c24f9-8141-400c-8c38-cdb37d3daf5c
4ae2893a-9d81-42f4-b470-85e637039109	Имя2	Отчество2	Фамилия2	b99c24f9-8141-400c-8c38-cdb37d3daf5c
0cdde8a9-1253-40f5-b473-c340ceaf813a	Имя3	Отчество3	Фамилия3	b99c24f9-8141-400c-8c38-cdb37d3daf5c
33532ab4-0af2-4a15-b7aa-75b2cc21e0e1	Имя4	Отчество4	Фамилия4	b99c24f9-8141-400c-8c38-cdb37d3daf5c
912e801e-17cf-4df5-833e-71244bd4ed4e	Имя5	Отчество5	Фамилия5	b99c24f9-8141-400c-8c38-cdb37d3daf5c
9d67a0ad-7f8b-4322-8644-cedde62b10ff	Имя6	Отчество6	Фамилия6	b99c24f9-8141-400c-8c38-cdb37d3daf5c
de157b04-1896-4ddc-b0dd-dc2dd7e3db46	Имя7	Отчество7	Фамилия7	b99c24f9-8141-400c-8c38-cdb37d3daf5c
2d0bfeef-2b8a-481c-a13b-5674fe4a024d	Имя8	Отчество8	Фамилия8	b99c24f9-8141-400c-8c38-cdb37d3daf5c
9645c3e9-4498-4ed9-99af-b777de16159e	Имя9	Отчество9	Фамилия9	b99c24f9-8141-400c-8c38-cdb37d3daf5c
7394e1a9-035a-4f46-9010-201cf94d543f	Имя10	Отчество10	Фамилия10	b99c24f9-8141-400c-8c38-cdb37d3daf5c
2a08060e-673d-4dc4-8207-705cd9f50356	Имя11	Отчество11	Фамилия11	b99c24f9-8141-400c-8c38-cdb37d3daf5c
292e43d2-47d3-4f76-9f8f-72db2bb1734b	Имя12	Отчество12	Фамилия12	b99c24f9-8141-400c-8c38-cdb37d3daf5c
a3b8feb6-cdd7-4dd9-812f-d73b2d5619c5	Имя13	Отчество13	Фамилия13	b99c24f9-8141-400c-8c38-cdb37d3daf5c
f31dacb5-9bee-4c38-b9d8-9e2e9d68c8f6	Имя14	Отчество14	Фамилия14	b99c24f9-8141-400c-8c38-cdb37d3daf5c
ea64bb52-2fd3-420b-96e0-168854abc3d3	Имя15	Отчество15	Фамилия15	b99c24f9-8141-400c-8c38-cdb37d3daf5c
8a77ade1-b146-4ab0-b5d1-6c9993db00a8	Имя16	Отчество16	Фамилия16	b99c24f9-8141-400c-8c38-cdb37d3daf5c
0256e2a4-18de-4337-b7fe-0f0dcf851a61	Имя17	Отчество17	Фамилия17	b99c24f9-8141-400c-8c38-cdb37d3daf5c
c6fd877d-6beb-47c4-b002-cddb48454774	Имя18	Отчество18	Фамилия18	b99c24f9-8141-400c-8c38-cdb37d3daf5c
e7325fc0-853a-4f73-9ade-f07ad39cf1f3	Имя19	Отчество19	Фамилия19	b99c24f9-8141-400c-8c38-cdb37d3daf5c
338c677b-f482-4c0a-8915-30c85079743e	Имя20	Отчество20	Фамилия20	b99c24f9-8141-400c-8c38-cdb37d3daf5c
2f06d10f-676c-4b51-ba98-13e9b1e5ec12	Имя21	Отчество21	Фамилия21	b28abc04-b83c-4522-97b3-b2c474c0ae08
34418926-9a60-49e9-a10f-c58bb0c5f14c	Имя22	Отчество22	Фамилия22	b28abc04-b83c-4522-97b3-b2c474c0ae08
1394282a-6a8b-46d4-905b-2e4791808df9	Имя23	Отчество23	Фамилия23	b28abc04-b83c-4522-97b3-b2c474c0ae08
1958cc0c-e5aa-4b92-a6b3-7ef094feb395	Имя24	Отчество24	Фамилия24	b28abc04-b83c-4522-97b3-b2c474c0ae08
8806afc6-151e-4a58-be1c-b6def9e51b87	Имя25	Отчество25	Фамилия25	b28abc04-b83c-4522-97b3-b2c474c0ae08
63cbe8d5-c743-41a5-89a5-af1a3ef3b7f5	Имя26	Отчество26	Фамилия26	b28abc04-b83c-4522-97b3-b2c474c0ae08
532602c4-7b0b-4c8a-93ad-b6d4ba05a8b0	Имя27	Отчество27	Фамилия27	b28abc04-b83c-4522-97b3-b2c474c0ae08
8d0cb79f-0b7f-4449-8c6e-714bd7fad5da	Имя28	Отчество28	Фамилия28	b28abc04-b83c-4522-97b3-b2c474c0ae08
2e44c447-3d6b-41ec-aa07-e83958bd35d5	Имя29	Отчество29	Фамилия29	b28abc04-b83c-4522-97b3-b2c474c0ae08
d466c4c5-7c3b-45a6-bf8e-1a2c56168bbf	Имя30	Отчество30	Фамилия30	b28abc04-b83c-4522-97b3-b2c474c0ae08
8395e4d1-89fc-47c3-a36d-cf0a889e80ed	Имя31	Отчество31	Фамилия31	b28abc04-b83c-4522-97b3-b2c474c0ae08
d677220f-45e3-4e84-92b0-f37f02c84919	Имя32	Отчество32	Фамилия32	b28abc04-b83c-4522-97b3-b2c474c0ae08
6270c9ee-b557-4de6-9cd1-2466297d4ffc	Имя33	Отчество33	Фамилия33	b28abc04-b83c-4522-97b3-b2c474c0ae08
cf130d9d-cb82-4178-88f0-854e9af510b7	Имя34	Отчество34	Фамилия34	b28abc04-b83c-4522-97b3-b2c474c0ae08
bee85c7e-6e9f-473a-ac52-7add2cf387ee	Имя35	Отчество35	Фамилия35	b28abc04-b83c-4522-97b3-b2c474c0ae08
1e44053a-98c6-4b4c-817b-223dccc5b067	Имя36	Отчество36	Фамилия36	b28abc04-b83c-4522-97b3-b2c474c0ae08
a03f98b3-5466-4c83-96dd-6018d8388fa9	Имя37	Отчество37	Фамилия37	b28abc04-b83c-4522-97b3-b2c474c0ae08
e96c5866-463e-430a-af22-3ad2fc8f9e36	Имя38	Отчество38	Фамилия38	b28abc04-b83c-4522-97b3-b2c474c0ae08
b8af0600-5463-48ac-b67f-d0d4ece23f25	Имя39	Отчество39	Фамилия39	b28abc04-b83c-4522-97b3-b2c474c0ae08
bccbfb2b-9dc6-469a-9742-33d889a0486d	Имя40	Отчество40	Фамилия40	b28abc04-b83c-4522-97b3-b2c474c0ae08
2ab4ea00-bb6f-4631-9202-93ae2971d6e6	Имя41	Отчество41	Фамилия41	bb8bd1de-f50e-49b0-b984-c2e7066e0436
aed87aee-d487-4558-8095-a88cc4bf9ff6	Имя42	Отчество42	Фамилия42	bb8bd1de-f50e-49b0-b984-c2e7066e0436
26be8619-fd70-4e13-94b7-735568ea82d7	Имя43	Отчество43	Фамилия43	bb8bd1de-f50e-49b0-b984-c2e7066e0436
88be355b-b152-4071-9f9c-741c1d7d83f8	Имя44	Отчество44	Фамилия44	bb8bd1de-f50e-49b0-b984-c2e7066e0436
53f6e22a-822e-4819-9506-02ed80ca66e6	Имя45	Отчество45	Фамилия45	bb8bd1de-f50e-49b0-b984-c2e7066e0436
a7a5fe0d-962f-46a6-9361-0db18ec11eca	Имя46	Отчество46	Фамилия46	bb8bd1de-f50e-49b0-b984-c2e7066e0436
b7909343-53d3-4c2f-bf3a-f4e2ca47d805	Имя47	Отчество47	Фамилия47	bb8bd1de-f50e-49b0-b984-c2e7066e0436
cc8a241c-b0a3-4a7b-a632-6073a46374c7	Имя48	Отчество48	Фамилия48	bb8bd1de-f50e-49b0-b984-c2e7066e0436
3e12dc69-ea5d-4e52-bc87-6b52f5aefef9	Имя49	Отчество49	Фамилия49	bb8bd1de-f50e-49b0-b984-c2e7066e0436
49217046-631c-4098-a232-0c225ebcaf6e	Имя50	Отчество50	Фамилия50	bb8bd1de-f50e-49b0-b984-c2e7066e0436
5379ebbc-9376-4aa8-80d0-949ec2fd5ac5	Имя51	Отчество51	Фамилия51	bb8bd1de-f50e-49b0-b984-c2e7066e0436
0b1e18c5-6194-4eb3-a25a-29ef79cb06f3	Имя52	Отчество52	Фамилия52	bb8bd1de-f50e-49b0-b984-c2e7066e0436
9abb6cdd-40e4-45b5-a00a-0d78239e29f1	Имя53	Отчество53	Фамилия53	bb8bd1de-f50e-49b0-b984-c2e7066e0436
ef2e96e9-86f0-461d-9633-4d28bf075108	Имя54	Отчество54	Фамилия54	bb8bd1de-f50e-49b0-b984-c2e7066e0436
86f85efa-d5b1-4ae8-b4d7-b06a34d6c6d8	Имя55	Отчество55	Фамилия55	bb8bd1de-f50e-49b0-b984-c2e7066e0436
43040892-66b1-44c1-803d-6227792a67c0	Имя56	Отчество56	Фамилия56	bb8bd1de-f50e-49b0-b984-c2e7066e0436
076f0569-e95a-4939-a4fa-735638b1a488	Имя57	Отчество57	Фамилия57	bb8bd1de-f50e-49b0-b984-c2e7066e0436
c444f646-d54f-453b-80d8-140bd3383194	Имя58	Отчество58	Фамилия58	bb8bd1de-f50e-49b0-b984-c2e7066e0436
9bcc5346-bc66-439b-a7e4-910bba42ceb7	Имя59	Отчество59	Фамилия59	bb8bd1de-f50e-49b0-b984-c2e7066e0436
31daa9f4-70f8-4585-9b97-085307be3c22	Имя60	Отчество60	Фамилия60	bb8bd1de-f50e-49b0-b984-c2e7066e0436
\.


--
-- Data for Name: subjects; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subjects (id, name) FROM stdin;
\.


--
-- Data for Name: temp_tokens; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.temp_tokens (user_id, temp_token, code, created_at, expires_at) FROM stdin;
\.


--
-- Data for Name: token; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.token (id, user_id, refresh_token, ip_address, user_agent, unique_id, created_at, expires_at, is_revoked) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, email, password, role) FROM stdin;
fd9005b3-99d8-4545-a983-f12190dab706	testadmin@mail.ru	$2b$10$oGmjm8JWRAR.FnZabt1N5.dxfrbej/ZASfugm9UF/Zwsnu4PKZzFK	admin
4ae2893a-9d81-42f4-b470-85e637039109	test2@mail.ru	$2b$10$rROawBWASo50tNbCDBf3.OIdwc9Rnkg5HHgRnXNts4v7k2VlnzSeO	student
0cdde8a9-1253-40f5-b473-c340ceaf813a	test3@mail.ru	$2b$10$HveWGqVLuUEbw9zb17VfmubS2RQ2dj5IPqqSbAiItk6flcs1Y9GdK	student
33532ab4-0af2-4a15-b7aa-75b2cc21e0e1	test4@mail.ru	$2b$10$hWQoL8N9gBtGtAW2IPJBIOvndYN/3LSkvnypbEeAF7F6YKNFVcDIS	student
912e801e-17cf-4df5-833e-71244bd4ed4e	test5@mail.ru	$2b$10$NxOyuCbrSZ3gyJZF23NMru6L0y03JfgfrpmVeA0mG9MI4hYy0db/i	student
9d67a0ad-7f8b-4322-8644-cedde62b10ff	test6@mail.ru	$2b$10$qrGmDuEriMc7VfdGOfiRsugC.YAykmUheeBPSml5jdXSQ72mJFLfu	student
de157b04-1896-4ddc-b0dd-dc2dd7e3db46	test7@mail.ru	$2b$10$rO4tro8s7wGPGXwYOzUVBuvuFxpJgd8t6fxp3ijb3cubBiam48lzK	student
2d0bfeef-2b8a-481c-a13b-5674fe4a024d	test8@mail.ru	$2b$10$7AjWsgdPcZIt4Tnn8JvrBunvgSyHwSCvV/e5qh/hu/w1Z/UmOUBRq	student
9645c3e9-4498-4ed9-99af-b777de16159e	test9@mail.ru	$2b$10$vor.HlCzSIbHvMsXme7iBuGVM643OI/SzM4jggOCw7j1.dLrSwKiG	student
7394e1a9-035a-4f46-9010-201cf94d543f	test10@mail.ru	$2b$10$yrHyHW5LT8OimsOdKn1M3uJwIdssxPlgMutJJj1GNhj3u/aqiPoIq	student
2a08060e-673d-4dc4-8207-705cd9f50356	test11@mail.ru	$2b$10$n0luHZEOyUNtHi6frANU7eLlYL5ONXyKOMGRbkTn0zWEeiq5HZ/.2	student
292e43d2-47d3-4f76-9f8f-72db2bb1734b	test12@mail.ru	$2b$10$GV9qkEELViLIkIQ2CtDCWu8.KRD.5HQ2ePkueghTk0x8Y/afLa0Se	student
a3b8feb6-cdd7-4dd9-812f-d73b2d5619c5	test13@mail.ru	$2b$10$UxS8FmdftSpJUQdMwe/ok.VlrdKYQLHfcgCIk12yz/JZg.AQ7OYY.	student
f31dacb5-9bee-4c38-b9d8-9e2e9d68c8f6	test14@mail.ru	$2b$10$WDWhLOOHGAm1.agRZJbmduncJM6DMkIy9QpBdm1gHk0b7qKR9yX5a	student
ea64bb52-2fd3-420b-96e0-168854abc3d3	test15@mail.ru	$2b$10$QcJJaJyq5uFODlpYBzFKiOhLqCqQJ8i9nQ6yA0IuCSxRXD45ToNTS	student
8a77ade1-b146-4ab0-b5d1-6c9993db00a8	test16@mail.ru	$2b$10$SCL.Kwm7jMXIFFzJAxRr8e2mErTqRz/iiXJ7o4LDL0HwOjfgrQmSC	student
0256e2a4-18de-4337-b7fe-0f0dcf851a61	test17@mail.ru	$2b$10$9BZYRTiuxILi4DDma.ilROJMv7h7pfQIXKK2zwbCBejrejIZ1NGBO	student
c6fd877d-6beb-47c4-b002-cddb48454774	test18@mail.ru	$2b$10$5V5q.9oJ2nPM8Xvgo1ab5OKh94fE0JCml41ixB3RjVhcv/r8FolvC	student
e7325fc0-853a-4f73-9ade-f07ad39cf1f3	test19@mail.ru	$2b$10$s.O5hCPiqyABjRWFFZ5rLOTwJAMc5QVwpQBkQrv1YhNxHsInJxncO	student
338c677b-f482-4c0a-8915-30c85079743e	test20@mail.ru	$2b$10$8U11qZX/MiV.31JLlHlh9OXX8uqmXfCaGQMuXvdvUqFIv6mYROMSC	student
2f06d10f-676c-4b51-ba98-13e9b1e5ec12	test21@mail.ru	$2b$10$AVw357m6tfRgLD4re/Iewuoz8qUx5KRsqIyfl3fcWN7IWtVo3EcA.	student
34418926-9a60-49e9-a10f-c58bb0c5f14c	test22@mail.ru	$2b$10$Xo93Xm.9LrGAPndqLTFPEOUvYR0lvVmnmL3qU/jNlQNSxmMBH5rfm	student
1394282a-6a8b-46d4-905b-2e4791808df9	test23@mail.ru	$2b$10$LzPhCPbVGPUX4QOpZUeyq.kL9j0AdjHF28hyzpRFUg3N5YkRiGrRq	student
1958cc0c-e5aa-4b92-a6b3-7ef094feb395	test24@mail.ru	$2b$10$cg5fGHaC9vRw/WpZoq1QjeheBQCd5s1XHGgla5ILq8H7yKvkZMcyO	student
8806afc6-151e-4a58-be1c-b6def9e51b87	test25@mail.ru	$2b$10$5.UvpTKpMKTgLeFAYCOaA.vn7r4BFrKqhota3S.X.rK6UdZ4JOpGu	student
63cbe8d5-c743-41a5-89a5-af1a3ef3b7f5	test26@mail.ru	$2b$10$e70OSu3rE9p1p6uJ0qQiG.UVTt7s93vBPjzan4M41T.uX8Orju3H6	student
532602c4-7b0b-4c8a-93ad-b6d4ba05a8b0	test27@mail.ru	$2b$10$VOv9WQ2Gw0sEut5.e9defezgq3ZbMoY5dj9arlwZ1wW7k6NBV3ovm	student
8d0cb79f-0b7f-4449-8c6e-714bd7fad5da	test28@mail.ru	$2b$10$jorys5NAePgqaLO2hrspEOVkkc9KgZHIUdwcCETGzGY0zauCSRKOy	student
2e44c447-3d6b-41ec-aa07-e83958bd35d5	test29@mail.ru	$2b$10$FS7aItBhRfJP4QgGei63OOleKF4SUrt9o/vsxQCmEXR8XZ/VXrdX2	student
d466c4c5-7c3b-45a6-bf8e-1a2c56168bbf	test30@mail.ru	$2b$10$Cn36sH9YnzkV2pLsb2bWX.FzxiORbsk3gY7prAiHXjmUtrcXtFPFS	student
8395e4d1-89fc-47c3-a36d-cf0a889e80ed	test31@mail.ru	$2b$10$6GaNKvQOglgOy8cMEI.LBuE4qRt0LtsLD3fVMav3jVb/9fFc0ysUK	student
d677220f-45e3-4e84-92b0-f37f02c84919	test32@mail.ru	$2b$10$UFcp1IrCVH51yL9Q7C24BuqZG1TlATproYLeB1i9IHF7ikqSWtqsC	student
6270c9ee-b557-4de6-9cd1-2466297d4ffc	test33@mail.ru	$2b$10$Xl.xd7ji5DsVjEHsbgekTunbCPBm085DQmE3idf6ML4jJ2HDRalJq	student
cf130d9d-cb82-4178-88f0-854e9af510b7	test34@mail.ru	$2b$10$nSI.ufLMA8TqomM50TMIpOwQ7TgiEwW4aun32CtfpfYRaJFmt5J4O	student
bee85c7e-6e9f-473a-ac52-7add2cf387ee	test35@mail.ru	$2b$10$rXduExenx28I98tNCFC7uu88p6TdKZtJUncb6EWKvD61akOZvXg.6	student
1e44053a-98c6-4b4c-817b-223dccc5b067	test36@mail.ru	$2b$10$1AcVnu2dKI18rY8ZlsROeOZbotuYPuwepPkqzT3br4HIuB.6177K.	student
a03f98b3-5466-4c83-96dd-6018d8388fa9	test37@mail.ru	$2b$10$4XNHAsLbXdnqcPG8YNIsxe8JNZmAL2xZ/px4HBthxi/4fgs4zA612	student
e96c5866-463e-430a-af22-3ad2fc8f9e36	test38@mail.ru	$2b$10$gJaX/WNCHs75EaJy6.2I9.38JVNqVh0yNdmjuezCHBoIHmzqdHRK.	student
b8af0600-5463-48ac-b67f-d0d4ece23f25	test39@mail.ru	$2b$10$Kp5SLd2cnL/aLFqul0qfb.FGODqlHaBYPz5FWZ028298k.OJHv4KG	student
bccbfb2b-9dc6-469a-9742-33d889a0486d	test40@mail.ru	$2b$10$OFKEDp.Z3DmVAumOTol4iOq0Ev0Al0RRs9GSGqKf9mHmKVauTor12	student
2ab4ea00-bb6f-4631-9202-93ae2971d6e6	test41@mail.ru	$2b$10$NuSCkCVXCTPI/61Z/OzJduvWtq/ws9i/DZLvvs5KhTg9Q8SnJfeau	student
aed87aee-d487-4558-8095-a88cc4bf9ff6	test42@mail.ru	$2b$10$ndbh9ewXPNtq.70EHh/hbeRIuAWq4yFi1.u2Pj66SHGyyo6/CRTcm	student
26be8619-fd70-4e13-94b7-735568ea82d7	test43@mail.ru	$2b$10$JgnrVd0VPhYWM6emAkv25eYMcCwJDayMtBZxWM9WqcBzvt5tyUK4.	student
88be355b-b152-4071-9f9c-741c1d7d83f8	test44@mail.ru	$2b$10$JW.8r.2k/./fElHS/3F3QO9PCJr0lrjOJ4z494OrbxGuqPPsZSLni	student
53f6e22a-822e-4819-9506-02ed80ca66e6	test45@mail.ru	$2b$10$ohG54Nr06DcpVvtbzyc8xeNylg1l505txGQVWJwQN9Ipu2tu4056C	student
a7a5fe0d-962f-46a6-9361-0db18ec11eca	test46@mail.ru	$2b$10$UGRfXu//3.plp4qLfm5E3u46qiGyWaV9TZ/hlNf0/Zi5ZNdwadseC	student
b7909343-53d3-4c2f-bf3a-f4e2ca47d805	test47@mail.ru	$2b$10$qGBtHCJppvlgSlnDYK2aUuRDQKIjCq.oORrDHS0ONoLLLbkpc1Bda	student
cc8a241c-b0a3-4a7b-a632-6073a46374c7	test48@mail.ru	$2b$10$85LbdCAKji4PeqvlIVLhguwf0KdaCfqYL/l5hoA0Dh9tNUOyuDcba	student
3e12dc69-ea5d-4e52-bc87-6b52f5aefef9	test49@mail.ru	$2b$10$iBBV/xGqppLqlyCDqPV1HOjMp3NvKWA30eC2UZ40mUccxTNkhfCd2	student
49217046-631c-4098-a232-0c225ebcaf6e	test50@mail.ru	$2b$10$PbsvsQUJXsvOfEzD0CxK4uEHLbXf6ZqaOI2m6ndlGkiO7t7CZGO72	student
5379ebbc-9376-4aa8-80d0-949ec2fd5ac5	test51@mail.ru	$2b$10$V2VrcjVul/8J8olNoKJILulYQksSmA/z8RcV.6ob8ldmJESYkcfve	student
0b1e18c5-6194-4eb3-a25a-29ef79cb06f3	test52@mail.ru	$2b$10$VvRfu.gKialI3OihkWetNeLVTT/eX1/W3zqKa/pSPoj0crAC8TVsC	student
9abb6cdd-40e4-45b5-a00a-0d78239e29f1	test53@mail.ru	$2b$10$IZMYrEywsX0GeMwSRLk5xunxQvwWzTFi8XaZMPlNUxs3j/ZGJY3Lu	student
ef2e96e9-86f0-461d-9633-4d28bf075108	test54@mail.ru	$2b$10$7gek4zvLGUKzKiMfpwIXp.cpGStxvcJcmckhNR4gQHWYcrXHH1DJC	student
86f85efa-d5b1-4ae8-b4d7-b06a34d6c6d8	test55@mail.ru	$2b$10$OyRF1TfCp0orqlLVQu7kY.EKPwOfk8pqJq46rz06ekmJC6LTc/E6u	student
43040892-66b1-44c1-803d-6227792a67c0	test56@mail.ru	$2b$10$/5YvhAcT84SJFCzctN4HOOv7gZ1Kz1eOMhkuKuFgEnFsrtwN7TCiy	student
076f0569-e95a-4939-a4fa-735638b1a488	test57@mail.ru	$2b$10$mfW2HNKwJZskqgNN1NV4MeMromunZ7sc3Po00wv/5dYRIjKvgP6Tm	student
c444f646-d54f-453b-80d8-140bd3383194	test58@mail.ru	$2b$10$0Th4P72EAshQsY0VSxkv4uASbSQyzQfuDuK6qmhlME6zotJMDKrpW	student
9bcc5346-bc66-439b-a7e4-910bba42ceb7	test59@mail.ru	$2b$10$y6BQ97O4TvKGsn7SF7W92uTyd16VyNGz8eDV95VPJ6wtcJXcWx7rG	student
31daa9f4-70f8-4585-9b97-085307be3c22	test60@mail.ru	$2b$10$P2ccAZDWSd9RLZimQO.95OBnZoReZlGSwRYpJXDQZnuD1gFVv0ciK	student
f489280e-6e51-44ff-9443-f3a053c04f78	test1@mail.ru	$2b$10$hlMW/KsjV4iFSfmJze1q0OGSQiBWqe//.sBvYXbKGWz2r8jy.hDbS	student
101008b8-9641-4428-bcd0-367434f16591	testlecturer@mail.ru	$2b$10$NQVfa2tp8VzqHXJhB0Ybdus8I7AMeQG89cCrWfLBUOARtDZlvZQRG	lecturer
\.


--
-- Name: groups groups_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_name_key UNIQUE (name);


--
-- Name: groups groups_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id);


--
-- Name: lab_files lab_files_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lab_files
    ADD CONSTRAINT lab_files_pkey PRIMARY KEY (id);


--
-- Name: lab_groups lab_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lab_groups
    ADD CONSTRAINT lab_groups_pkey PRIMARY KEY (lab_id, group_id);


--
-- Name: lab_submission_files lab_submission_files_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lab_submission_files
    ADD CONSTRAINT lab_submission_files_pkey PRIMARY KEY (id);


--
-- Name: lab_submissions lab_submissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lab_submissions
    ADD CONSTRAINT lab_submissions_pkey PRIMARY KEY (id);


--
-- Name: labs labs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.labs
    ADD CONSTRAINT labs_pkey PRIMARY KEY (id);


--
-- Name: lecturer_groups lecturer_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lecturer_groups
    ADD CONSTRAINT lecturer_groups_pkey PRIMARY KEY (lecturer_id, group_id);


--
-- Name: lecturer_subjects lecturer_subjects_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lecturer_subjects
    ADD CONSTRAINT lecturer_subjects_pkey PRIMARY KEY (lecturer_id, subject_id);


--
-- Name: lecturers lecturers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lecturers
    ADD CONSTRAINT lecturers_pkey PRIMARY KEY (user_id);


--
-- Name: students students_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_pkey PRIMARY KEY (user_id);


--
-- Name: subjects subjects_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subjects
    ADD CONSTRAINT subjects_name_key UNIQUE (name);


--
-- Name: subjects subjects_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subjects
    ADD CONSTRAINT subjects_pkey PRIMARY KEY (id);


--
-- Name: temp_tokens temp_tokens_user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.temp_tokens
    ADD CONSTRAINT temp_tokens_user_id_key UNIQUE (user_id);


--
-- Name: token token_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.token
    ADD CONSTRAINT token_pkey PRIMARY KEY (id);


--
-- Name: token token_user_id_unique_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.token
    ADD CONSTRAINT token_user_id_unique_id_key UNIQUE (user_id, unique_id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: lab_files lab_files_lab_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lab_files
    ADD CONSTRAINT lab_files_lab_id_fkey FOREIGN KEY (lab_id) REFERENCES public.labs(id) ON DELETE CASCADE;


--
-- Name: lab_groups lab_groups_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lab_groups
    ADD CONSTRAINT lab_groups_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.groups(id) ON DELETE CASCADE;


--
-- Name: lab_groups lab_groups_lab_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lab_groups
    ADD CONSTRAINT lab_groups_lab_id_fkey FOREIGN KEY (lab_id) REFERENCES public.labs(id) ON DELETE CASCADE;


--
-- Name: lab_submission_files lab_submission_files_lab_submission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lab_submission_files
    ADD CONSTRAINT lab_submission_files_lab_submission_id_fkey FOREIGN KEY (lab_submission_id) REFERENCES public.lab_submissions(id) ON DELETE CASCADE;


--
-- Name: lab_submissions lab_submissions_lab_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lab_submissions
    ADD CONSTRAINT lab_submissions_lab_id_fkey FOREIGN KEY (lab_id) REFERENCES public.labs(id) ON DELETE CASCADE;


--
-- Name: lab_submissions lab_submissions_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lab_submissions
    ADD CONSTRAINT lab_submissions_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.students(user_id) ON DELETE CASCADE;


--
-- Name: labs labs_lecturer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.labs
    ADD CONSTRAINT labs_lecturer_id_fkey FOREIGN KEY (lecturer_id) REFERENCES public.lecturers(user_id) ON DELETE RESTRICT;


--
-- Name: labs labs_subject_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.labs
    ADD CONSTRAINT labs_subject_id_fkey FOREIGN KEY (subject_id) REFERENCES public.subjects(id) ON DELETE CASCADE;


--
-- Name: lecturer_groups lecturer_groups_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lecturer_groups
    ADD CONSTRAINT lecturer_groups_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.groups(id) ON DELETE CASCADE;


--
-- Name: lecturer_groups lecturer_groups_lecturer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lecturer_groups
    ADD CONSTRAINT lecturer_groups_lecturer_id_fkey FOREIGN KEY (lecturer_id) REFERENCES public.lecturers(user_id) ON DELETE CASCADE;


--
-- Name: lecturer_subjects lecturer_subjects_lecturer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lecturer_subjects
    ADD CONSTRAINT lecturer_subjects_lecturer_id_fkey FOREIGN KEY (lecturer_id) REFERENCES public.lecturers(user_id) ON DELETE CASCADE;


--
-- Name: lecturer_subjects lecturer_subjects_subject_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lecturer_subjects
    ADD CONSTRAINT lecturer_subjects_subject_id_fkey FOREIGN KEY (subject_id) REFERENCES public.subjects(id) ON DELETE CASCADE;


--
-- Name: lecturers lecturers_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lecturers
    ADD CONSTRAINT lecturers_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: students students_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.groups(id) ON DELETE SET NULL;


--
-- Name: students students_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: temp_tokens temp_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.temp_tokens
    ADD CONSTRAINT temp_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: token token_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.token
    ADD CONSTRAINT token_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

