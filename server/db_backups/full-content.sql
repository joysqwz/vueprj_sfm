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

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO postgres;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA public IS '';


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
-- Name: tokens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tokens (
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


ALTER TABLE public.tokens OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id uuid NOT NULL,
    email character varying(255) NOT NULL,
    password character varying(255) NOT NULL,
    role character varying(20) NOT NULL,
    CONSTRAINT users_role_check CHECK (((role)::text = ANY (ARRAY[('admin'::character varying)::text, ('lecturer'::character varying)::text, ('student'::character varying)::text])))
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Data for Name: groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.groups (id, name) FROM stdin;
97d89647-7115-4e86-a86e-39887297835f	ПО1-21
34906a73-5729-487b-9c10-77c254efb9d5	ПО2-21
fc561e17-c545-4174-bba0-289a189df90d	АС-21
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
26eb2041-66e6-485b-bdfb-20c9d9e623aa	fc561e17-c545-4174-bba0-289a189df90d
26eb2041-66e6-485b-bdfb-20c9d9e623aa	97d89647-7115-4e86-a86e-39887297835f
26eb2041-66e6-485b-bdfb-20c9d9e623aa	34906a73-5729-487b-9c10-77c254efb9d5
c2e066ce-5cc2-47ff-9f3f-5c95949fdd74	fc561e17-c545-4174-bba0-289a189df90d
c2e066ce-5cc2-47ff-9f3f-5c95949fdd74	97d89647-7115-4e86-a86e-39887297835f
c2e066ce-5cc2-47ff-9f3f-5c95949fdd74	34906a73-5729-487b-9c10-77c254efb9d5
4671b7aa-800a-4ee9-9229-a39d3e6230fb	fc561e17-c545-4174-bba0-289a189df90d
4671b7aa-800a-4ee9-9229-a39d3e6230fb	97d89647-7115-4e86-a86e-39887297835f
4671b7aa-800a-4ee9-9229-a39d3e6230fb	34906a73-5729-487b-9c10-77c254efb9d5
58855f44-a4f1-4a33-b446-63936dd87231	fc561e17-c545-4174-bba0-289a189df90d
58855f44-a4f1-4a33-b446-63936dd87231	97d89647-7115-4e86-a86e-39887297835f
58855f44-a4f1-4a33-b446-63936dd87231	34906a73-5729-487b-9c10-77c254efb9d5
47f4b7fe-8642-4a38-a1d3-dab378b302d7	fc561e17-c545-4174-bba0-289a189df90d
47f4b7fe-8642-4a38-a1d3-dab378b302d7	97d89647-7115-4e86-a86e-39887297835f
47f4b7fe-8642-4a38-a1d3-dab378b302d7	34906a73-5729-487b-9c10-77c254efb9d5
8f9d8a5d-9fac-4975-91bb-b8ee5aa03130	fc561e17-c545-4174-bba0-289a189df90d
8f9d8a5d-9fac-4975-91bb-b8ee5aa03130	97d89647-7115-4e86-a86e-39887297835f
8f9d8a5d-9fac-4975-91bb-b8ee5aa03130	34906a73-5729-487b-9c10-77c254efb9d5
dfaaf8c4-fa33-4200-9ee5-4daa39422c27	fc561e17-c545-4174-bba0-289a189df90d
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
55081dbf-2601-4204-8b18-fa7e0a3704e8	26eb2041-66e6-485b-bdfb-20c9d9e623aa	c19cafba-aeb4-4a0c-99b2-cf4a84880394	\N	\N
1b31dcb3-e6f3-4a19-b2e3-a98a65dd6420	26eb2041-66e6-485b-bdfb-20c9d9e623aa	02b972ab-70b6-43a4-8c52-97459d560128	\N	\N
9230a803-2dd0-4cb1-9f5e-f898b950944b	26eb2041-66e6-485b-bdfb-20c9d9e623aa	326bd3ae-1b5f-47b1-853f-1516a7182669	\N	\N
f8dcfe57-2577-4b6a-9ea6-8c34b1946fa8	26eb2041-66e6-485b-bdfb-20c9d9e623aa	3297f494-5c84-4607-a9c7-0cd373202fb7	\N	\N
634442be-da21-49da-aa46-ee150321a211	26eb2041-66e6-485b-bdfb-20c9d9e623aa	f762ddee-2a3b-4d4b-aa3d-d404e517fa69	\N	\N
fb1a6411-a651-44d9-adb4-cc2b371a76ea	26eb2041-66e6-485b-bdfb-20c9d9e623aa	7aa1739e-1dd3-4ea5-8d82-ac738f77a9a3	\N	\N
57488fc0-df0c-477a-908d-feacadc09c08	26eb2041-66e6-485b-bdfb-20c9d9e623aa	98dc56aa-2b01-4639-aa73-ab9b865e272d	\N	\N
a8e6b7c1-584a-41d5-9118-7d4d2b94286e	26eb2041-66e6-485b-bdfb-20c9d9e623aa	a5d9f334-465d-4f30-8e49-1de5a588dd7e	\N	\N
f4eb14f8-498c-4d90-8e10-cd9e91a38c4d	26eb2041-66e6-485b-bdfb-20c9d9e623aa	68fdc69d-6b79-45c5-ab30-30e1aefdafa4	\N	\N
2a730e60-9ed5-487e-ade4-16132c196c57	26eb2041-66e6-485b-bdfb-20c9d9e623aa	e1a3727c-1f71-4b07-80eb-31b202f61908	\N	\N
77559a6d-1d3b-43e9-8346-d846ce785180	26eb2041-66e6-485b-bdfb-20c9d9e623aa	8079ef20-ca48-413d-abff-9bddd3ad7379	\N	\N
c41d2fbd-47af-4eb6-ae2f-25172dd8ee95	26eb2041-66e6-485b-bdfb-20c9d9e623aa	714354ab-5a24-448f-805b-05c846c13597	\N	\N
7e5498f5-bbbb-47c8-a397-5b2f99f0abcb	26eb2041-66e6-485b-bdfb-20c9d9e623aa	fed9b0f1-374f-443d-93b8-a68cfef0f8d0	\N	\N
9b13fde1-96bf-4f8a-a9c6-5d3cd37f2ecb	26eb2041-66e6-485b-bdfb-20c9d9e623aa	c4b8d77b-797f-49b6-9ea8-7717d095997a	\N	\N
bb35a40a-c642-4b2b-8614-12e305e09075	c2e066ce-5cc2-47ff-9f3f-5c95949fdd74	becc9d63-42d7-4fbf-b833-49a7c244520d	\N	\N
5ff9cd6d-5983-4aa8-b75f-0bddef45b765	c2e066ce-5cc2-47ff-9f3f-5c95949fdd74	e2a958ad-948b-4862-b15c-b2145ef2a440	\N	\N
df96c9b4-8aea-4cc3-9079-efbe7a9219f3	c2e066ce-5cc2-47ff-9f3f-5c95949fdd74	1459c1e8-4c40-42aa-bc76-719365d9b84f	0	\N
e3c3f9d2-2294-4faa-94c0-59ba46e3daae	c2e066ce-5cc2-47ff-9f3f-5c95949fdd74	714354ab-5a24-448f-805b-05c846c13597	1	\N
43003b9b-4245-46cd-b95d-3859151ba804	c2e066ce-5cc2-47ff-9f3f-5c95949fdd74	0ac60ce0-9b6b-457e-ab20-1c4d3e6b8164	0	\N
fef436b3-3a8a-4c5b-9aff-cce97a7b26ac	c2e066ce-5cc2-47ff-9f3f-5c95949fdd74	8ed3ffcc-3b59-47bf-9de4-36224220edc0	2	\N
2d2c1840-b563-455b-aab4-7336911d1ee2	c2e066ce-5cc2-47ff-9f3f-5c95949fdd74	b5bacf10-72cd-4499-87e1-7acd901f0eba	2	\N
a86704ab-0614-45f3-9889-9c2e1ee06a36	c2e066ce-5cc2-47ff-9f3f-5c95949fdd74	e0219d86-839f-447a-a310-4a7cc34af686	2	\N
3ba585aa-ebf7-4629-8b5e-78d356d58019	c2e066ce-5cc2-47ff-9f3f-5c95949fdd74	8114e989-f75e-43a0-9925-eb66ea58e908	2	\N
2cf43726-9bff-4542-bb0c-6c7a7dba9ce6	c2e066ce-5cc2-47ff-9f3f-5c95949fdd74	f60c4cac-9215-452f-bcee-446724b4c5df	2	\N
b93941f1-f7db-4f9b-9a87-653d8c5f4e30	c2e066ce-5cc2-47ff-9f3f-5c95949fdd74	56fbc3fc-0d8b-4e53-bc71-f16dff24d03f	0	\N
c6e05db5-81d0-4bd7-ae70-7161d8e4d80d	c2e066ce-5cc2-47ff-9f3f-5c95949fdd74	2d294931-dfb0-4ab3-a453-93c8b791d853	2	\N
2dadd66f-0d0a-4b95-b3dd-341e31c6c399	c2e066ce-5cc2-47ff-9f3f-5c95949fdd74	7130dde9-c15e-462d-9384-b560e1b10693	0	\N
1bb9dc83-76dd-41b4-87cc-dd77614bd182	c2e066ce-5cc2-47ff-9f3f-5c95949fdd74	99094616-1233-481d-be5f-d59fc0e8b3ee	2	\N
d58f892e-a2e5-4648-87c0-a5ef90b5fa14	c2e066ce-5cc2-47ff-9f3f-5c95949fdd74	c1f28dd0-c438-49da-b093-f27a29a4fbe4	0	\N
4a2eb925-8cf0-4720-8cc2-7f4a67470b3b	c2e066ce-5cc2-47ff-9f3f-5c95949fdd74	c976199c-dc57-4144-9b8a-811380ecde1b	0	\N
d39ded7b-b5c4-47a6-9211-cf06e2b30c87	c2e066ce-5cc2-47ff-9f3f-5c95949fdd74	c19cafba-aeb4-4a0c-99b2-cf4a84880394	0	\N
40ae1fa0-608a-458c-b0a6-fa7c4adec639	c2e066ce-5cc2-47ff-9f3f-5c95949fdd74	9bf793be-ca7b-4d9d-97d7-59de82bffc28	2	\N
b9a75ed9-7735-4982-92bf-c620346ead86	c2e066ce-5cc2-47ff-9f3f-5c95949fdd74	3297f494-5c84-4607-a9c7-0cd373202fb7	1	\N
21080d2a-4e16-46e3-828c-a010c9423280	c2e066ce-5cc2-47ff-9f3f-5c95949fdd74	88a9cae7-4199-4255-84bb-918efee13770	1	\N
bbf3eb25-36ef-4098-8e15-f199664f42a2	c2e066ce-5cc2-47ff-9f3f-5c95949fdd74	02b972ab-70b6-43a4-8c52-97459d560128	1	\N
e7746e85-b7d7-4a01-b417-81f150bba22b	c2e066ce-5cc2-47ff-9f3f-5c95949fdd74	f762ddee-2a3b-4d4b-aa3d-d404e517fa69	1	\N
737cb662-aa78-4c29-a6e1-cced563ba6ba	c2e066ce-5cc2-47ff-9f3f-5c95949fdd74	14f29127-0c8b-4ec4-a7fa-f746ce8fa750	2	\N
dae170f8-e76e-4091-a4b1-35e65b88d752	c2e066ce-5cc2-47ff-9f3f-5c95949fdd74	7aa1739e-1dd3-4ea5-8d82-ac738f77a9a3	2	\N
81464115-a836-432b-86bd-8d5dd6629f65	c2e066ce-5cc2-47ff-9f3f-5c95949fdd74	0ba08c51-4ea3-4b96-b210-689f33edf0ff	0	\N
91cd0039-3f38-4e75-967f-6ec93b5c54f6	c2e066ce-5cc2-47ff-9f3f-5c95949fdd74	7c8a5806-8bf0-4872-a69b-61dcc97a46a6	0	\N
2a5de8e3-4759-485b-a15d-cf74e0e83b1a	c2e066ce-5cc2-47ff-9f3f-5c95949fdd74	df93db84-806c-4a93-99ed-c4ce6a35da56	0	\N
a2bd6512-704b-403a-aeab-9aaacd4821ed	c2e066ce-5cc2-47ff-9f3f-5c95949fdd74	d6c128a2-99da-4d80-937c-f684983e5171	0	\N
eb24f70b-1a71-4273-b07a-f112ee5c9a9f	c2e066ce-5cc2-47ff-9f3f-5c95949fdd74	d0c602c2-6839-4e42-848e-959de7613821	2	\N
39055695-a454-484e-b2da-46274e225159	c2e066ce-5cc2-47ff-9f3f-5c95949fdd74	e6a47da4-51ad-465c-bd95-4309370ee6b1	1	\N
c0475222-845a-4713-b899-681dd6d50c0a	c2e066ce-5cc2-47ff-9f3f-5c95949fdd74	7c34f4cf-f819-45a1-89e2-390cab528977	2	\N
ce985f52-85d4-4e48-9dab-c718c06cea21	c2e066ce-5cc2-47ff-9f3f-5c95949fdd74	e1a3727c-1f71-4b07-80eb-31b202f61908	2	\N
bab9b437-6dc5-4ff7-9b57-666223d87e0d	c2e066ce-5cc2-47ff-9f3f-5c95949fdd74	6f57f38f-f572-49af-9758-26d6e57a5746	2	\N
19569aa0-aa3a-4a76-b49a-dd3fcf82f17e	c2e066ce-5cc2-47ff-9f3f-5c95949fdd74	98dc56aa-2b01-4639-aa73-ab9b865e272d	1	\N
8bf3c13b-7008-40f8-a022-b1b5eb456ff3	c2e066ce-5cc2-47ff-9f3f-5c95949fdd74	846e69cc-27e8-4308-9288-87c02b34d4a3	0	\N
66f667d1-ea53-44b2-97f5-fa46bdb9055f	c2e066ce-5cc2-47ff-9f3f-5c95949fdd74	2d58fa47-92c7-4635-a06f-48b23e7ca061	0	\N
c0007789-8549-47b5-a5a4-48ca0092f029	c2e066ce-5cc2-47ff-9f3f-5c95949fdd74	dc1436c8-09d6-4c1d-b8b4-b71e501a6621	0	\N
d029172e-d39a-4e62-b599-0060bb1e1a94	26eb2041-66e6-485b-bdfb-20c9d9e623aa	b2d60abd-bf77-4f16-be34-3f5b62352885	2	\N
4be68e87-babf-4574-92db-ff1ec8f6d380	c2e066ce-5cc2-47ff-9f3f-5c95949fdd74	99de9373-47b9-4267-9741-de7b79d4f344	1	\N
a0679d88-1733-4390-8929-c907115e7c12	c2e066ce-5cc2-47ff-9f3f-5c95949fdd74	68fdc69d-6b79-45c5-ab30-30e1aefdafa4	1	\N
d5706be9-37d6-41af-b0a8-d190fbaca08e	c2e066ce-5cc2-47ff-9f3f-5c95949fdd74	5faeffea-c30f-4bee-aca3-630b3ba24377	1	\N
dd5ad263-5f8e-4930-adb9-006f906a9b8e	26eb2041-66e6-485b-bdfb-20c9d9e623aa	4568ab20-a2ce-4cfa-91cd-9f4a1de997de	0	\N
b15471e5-5b03-4131-92d6-33abbd51dd98	26eb2041-66e6-485b-bdfb-20c9d9e623aa	21149ade-6555-4c27-a52f-3969e568354e	0	\N
a7cef9ec-5313-4f51-9d12-dc57da2be01c	26eb2041-66e6-485b-bdfb-20c9d9e623aa	d0cdaa45-472a-401d-ab1d-6c9628afc382	0	\N
9d3b8f62-e9bf-4ae1-b2cd-3d40f3ca0a49	26eb2041-66e6-485b-bdfb-20c9d9e623aa	d131b6cc-e56f-42ef-a9ee-f12bb1059ac5	0	\N
e2a73718-4956-4b0b-95c0-0a25b7a53166	26eb2041-66e6-485b-bdfb-20c9d9e623aa	4bddca33-9207-4b6c-a284-23e7fc1f8beb	0	\N
d3348897-1d35-4739-9a64-99ee28928240	26eb2041-66e6-485b-bdfb-20c9d9e623aa	3eccc514-0bed-40c4-ac6d-84741b75ee0f	2	\N
b33e57ea-f492-47d6-b478-6f70e1dd8c30	26eb2041-66e6-485b-bdfb-20c9d9e623aa	0ac60ce0-9b6b-457e-ab20-1c4d3e6b8164	2	\N
a3dcd82a-de43-4e9a-b33b-c290eab26320	26eb2041-66e6-485b-bdfb-20c9d9e623aa	a5ebb569-491e-4f0c-9198-74711d119edc	0	\N
caba4149-9803-40e2-a3bb-7bbba3e49311	26eb2041-66e6-485b-bdfb-20c9d9e623aa	8ed3ffcc-3b59-47bf-9de4-36224220edc0	2	\N
7079a666-4a64-48a2-a514-f19a0a9b392c	26eb2041-66e6-485b-bdfb-20c9d9e623aa	be7340fc-7ef9-47fb-9ee6-66e8bdf4528a	2	\N
8a2ecd61-e51f-4457-b307-dfc5466fcd05	26eb2041-66e6-485b-bdfb-20c9d9e623aa	b5bacf10-72cd-4499-87e1-7acd901f0eba	2	\N
57623dc4-b1af-4948-bf0e-28d1f358ff30	26eb2041-66e6-485b-bdfb-20c9d9e623aa	9a2d4ac0-c0ab-4e3a-a8d3-f0e184ef3d21	2	\N
b72e161a-cef4-4b10-8113-ca9f865441d7	26eb2041-66e6-485b-bdfb-20c9d9e623aa	e0219d86-839f-447a-a310-4a7cc34af686	2	\N
fb628840-7be9-4f01-96e4-da758b00b84e	26eb2041-66e6-485b-bdfb-20c9d9e623aa	bab68678-edd4-4485-8d72-ae998cdf02d0	2	\N
bf59bc46-a23c-426f-8216-dbd66d6358cd	26eb2041-66e6-485b-bdfb-20c9d9e623aa	37c642e6-ec0f-4011-afd8-0d2bb77411a3	1	\N
cc443e4a-e412-4f94-965e-7bbee5510302	26eb2041-66e6-485b-bdfb-20c9d9e623aa	f60c4cac-9215-452f-bcee-446724b4c5df	2	\N
eed397f6-62ec-43d2-8edc-df46483adb5b	26eb2041-66e6-485b-bdfb-20c9d9e623aa	2d294931-dfb0-4ab3-a453-93c8b791d853	2	\N
7e1a5389-cc71-4858-a8c2-0d54eabf5195	26eb2041-66e6-485b-bdfb-20c9d9e623aa	7130dde9-c15e-462d-9384-b560e1b10693	2	\N
ee925cfe-1efe-4fff-a632-dd0abe8a0f19	26eb2041-66e6-485b-bdfb-20c9d9e623aa	99094616-1233-481d-be5f-d59fc0e8b3ee	1	\N
8267820b-460d-42c0-8b5d-7add42f428e8	26eb2041-66e6-485b-bdfb-20c9d9e623aa	56fbc3fc-0d8b-4e53-bc71-f16dff24d03f	1	\N
371f8b3b-2b04-41f4-a167-13eb253e2405	26eb2041-66e6-485b-bdfb-20c9d9e623aa	c976199c-dc57-4144-9b8a-811380ecde1b	0	\N
85eeb779-22ac-48e6-84bd-a2f67fc4e832	26eb2041-66e6-485b-bdfb-20c9d9e623aa	c1f28dd0-c438-49da-b093-f27a29a4fbe4	0	\N
cb9053f8-320b-4175-b742-d7f3453fb318	26eb2041-66e6-485b-bdfb-20c9d9e623aa	88a9cae7-4199-4255-84bb-918efee13770	0	\N
8dfb0d47-8b42-46c8-b8ee-f31b32245d5d	26eb2041-66e6-485b-bdfb-20c9d9e623aa	14f29127-0c8b-4ec4-a7fa-f746ce8fa750	0	\N
47eb7f48-02de-4b5f-a4c8-e681a40d9b90	26eb2041-66e6-485b-bdfb-20c9d9e623aa	7c8a5806-8bf0-4872-a69b-61dcc97a46a6	2	\N
b5714d3f-6750-43f2-b41d-f0749e010e1d	26eb2041-66e6-485b-bdfb-20c9d9e623aa	0ba08c51-4ea3-4b96-b210-689f33edf0ff	1	\N
ee253d49-a468-4aec-8eca-59c1058a07d4	26eb2041-66e6-485b-bdfb-20c9d9e623aa	df93db84-806c-4a93-99ed-c4ce6a35da56	2	\N
99d75273-3050-42cd-ad02-a8cd306cb93b	26eb2041-66e6-485b-bdfb-20c9d9e623aa	d6c128a2-99da-4d80-937c-f684983e5171	1	\N
2126a5ee-0142-426c-a26d-189cb744160c	26eb2041-66e6-485b-bdfb-20c9d9e623aa	e679ba89-1ef1-472f-b524-858c00d5ac2d	2	\N
3cf480e9-cc2d-4c7d-ad79-e17d6bc91823	26eb2041-66e6-485b-bdfb-20c9d9e623aa	e6a47da4-51ad-465c-bd95-4309370ee6b1	2	\N
667ae1e0-576a-49e9-ba5d-4af85be94c4e	26eb2041-66e6-485b-bdfb-20c9d9e623aa	d0c602c2-6839-4e42-848e-959de7613821	2	\N
43d50100-d0ce-4c9d-a22d-6feedc14a7b0	26eb2041-66e6-485b-bdfb-20c9d9e623aa	2d58fa47-92c7-4635-a06f-48b23e7ca061	2	\N
9b868300-f860-42ac-8e9b-b6597b38fa04	26eb2041-66e6-485b-bdfb-20c9d9e623aa	7c34f4cf-f819-45a1-89e2-390cab528977	1	\N
31dc3611-5c21-4ef9-a0a8-6b475ef00666	26eb2041-66e6-485b-bdfb-20c9d9e623aa	becc9d63-42d7-4fbf-b833-49a7c244520d	1	\N
0b900304-b7e5-4f9a-8d35-5bac09a23ad1	26eb2041-66e6-485b-bdfb-20c9d9e623aa	6f57f38f-f572-49af-9758-26d6e57a5746	1	\N
887dcd52-06d8-48ea-92d4-237ffe4b0b46	26eb2041-66e6-485b-bdfb-20c9d9e623aa	dc1436c8-09d6-4c1d-b8b4-b71e501a6621	2	\N
e292d44e-42e7-4e93-a6f8-1840ac870d3a	26eb2041-66e6-485b-bdfb-20c9d9e623aa	99de9373-47b9-4267-9741-de7b79d4f344	1	\N
20ee071f-d4d9-4b20-abe1-53857e96f935	26eb2041-66e6-485b-bdfb-20c9d9e623aa	5faeffea-c30f-4bee-aca3-630b3ba24377	1	\N
2209ac53-13a2-4b42-b15f-6a589ca1d56d	4671b7aa-800a-4ee9-9229-a39d3e6230fb	9bf793be-ca7b-4d9d-97d7-59de82bffc28	\N	\N
703b3379-9fbf-418f-acb0-ac05734b7433	4671b7aa-800a-4ee9-9229-a39d3e6230fb	02b972ab-70b6-43a4-8c52-97459d560128	\N	\N
74b0eadf-4881-4e91-9a53-55f15a2746d3	4671b7aa-800a-4ee9-9229-a39d3e6230fb	7aa1739e-1dd3-4ea5-8d82-ac738f77a9a3	\N	\N
c05473e0-a186-4d56-9ec6-b491d5fe4334	4671b7aa-800a-4ee9-9229-a39d3e6230fb	14f29127-0c8b-4ec4-a7fa-f746ce8fa750	\N	\N
bbb10dc8-d117-4e83-a316-3506c0a7dc4e	4671b7aa-800a-4ee9-9229-a39d3e6230fb	df93db84-806c-4a93-99ed-c4ce6a35da56	\N	\N
033e7c1d-0b0f-410b-b8dc-d604455fe346	4671b7aa-800a-4ee9-9229-a39d3e6230fb	0ba08c51-4ea3-4b96-b210-689f33edf0ff	\N	\N
0f615779-34e3-426c-8cdf-1c40063381b8	4671b7aa-800a-4ee9-9229-a39d3e6230fb	6e7aaf17-cee5-41ac-8637-0dca686d1f72	0	\N
fd18e4c9-ce16-435a-8334-c2713abc4525	4671b7aa-800a-4ee9-9229-a39d3e6230fb	4568ab20-a2ce-4cfa-91cd-9f4a1de997de	0	\N
8ebfdabc-caab-4db5-9eb4-754327c5bd00	4671b7aa-800a-4ee9-9229-a39d3e6230fb	b2d60abd-bf77-4f16-be34-3f5b62352885	0	\N
9120b818-cd3e-4f2b-8d4a-c645cd9e4d15	4671b7aa-800a-4ee9-9229-a39d3e6230fb	21149ade-6555-4c27-a52f-3969e568354e	0	\N
0f0297b8-a787-486c-a63e-8e4dc4e78d13	4671b7aa-800a-4ee9-9229-a39d3e6230fb	8079ef20-ca48-413d-abff-9bddd3ad7379	0	\N
ba0ccabb-2a87-4af1-b333-495cb4bc1554	4671b7aa-800a-4ee9-9229-a39d3e6230fb	c4b8d77b-797f-49b6-9ea8-7717d095997a	1	\N
418cabd5-319c-4696-ba21-c3acde7c51d3	4671b7aa-800a-4ee9-9229-a39d3e6230fb	d0cdaa45-472a-401d-ab1d-6c9628afc382	2	\N
2c9949d3-aaf6-4597-aa4e-d9c85774e411	4671b7aa-800a-4ee9-9229-a39d3e6230fb	714354ab-5a24-448f-805b-05c846c13597	2	\N
cb85a4b8-05b8-4baa-8afa-04b0ac6627c1	4671b7aa-800a-4ee9-9229-a39d3e6230fb	d131b6cc-e56f-42ef-a9ee-f12bb1059ac5	2	\N
385ea0c1-6f2f-4aca-818b-6464e6052578	4671b7aa-800a-4ee9-9229-a39d3e6230fb	fed9b0f1-374f-443d-93b8-a68cfef0f8d0	0	\N
29e420cf-afd9-4589-b612-c542587a509b	4671b7aa-800a-4ee9-9229-a39d3e6230fb	3eccc514-0bed-40c4-ac6d-84741b75ee0f	1	\N
37298043-bfa2-4f71-aa85-8db2ae3d808f	4671b7aa-800a-4ee9-9229-a39d3e6230fb	4bddca33-9207-4b6c-a284-23e7fc1f8beb	1	\N
04d7de44-1912-4dec-b7e0-90b8f4990259	4671b7aa-800a-4ee9-9229-a39d3e6230fb	0ac60ce0-9b6b-457e-ab20-1c4d3e6b8164	2	\N
f87d1a4f-a5f6-4a31-8d18-2c7664127abf	4671b7aa-800a-4ee9-9229-a39d3e6230fb	1459c1e8-4c40-42aa-bc76-719365d9b84f	2	\N
6110c98d-c207-4bbe-b3d5-02afd21362c5	4671b7aa-800a-4ee9-9229-a39d3e6230fb	a5ebb569-491e-4f0c-9198-74711d119edc	2	\N
1fda3bba-6ce6-489f-a812-1d354c64cbb6	4671b7aa-800a-4ee9-9229-a39d3e6230fb	be7340fc-7ef9-47fb-9ee6-66e8bdf4528a	1	\N
c2239e16-0c6d-43d7-9f9e-db69da84cab9	4671b7aa-800a-4ee9-9229-a39d3e6230fb	4198b0fc-8c96-4f3f-a538-d34b39045cdf	2	\N
82be393c-826d-4933-b29e-055343eb0015	4671b7aa-800a-4ee9-9229-a39d3e6230fb	8ed3ffcc-3b59-47bf-9de4-36224220edc0	2	\N
564bda7e-5642-4f43-8161-f7448a49b230	4671b7aa-800a-4ee9-9229-a39d3e6230fb	b5bacf10-72cd-4499-87e1-7acd901f0eba	1	\N
73225793-fd76-46a1-8142-aebe655621d4	4671b7aa-800a-4ee9-9229-a39d3e6230fb	9a2d4ac0-c0ab-4e3a-a8d3-f0e184ef3d21	2	\N
e5de23d9-ccf7-4777-ab23-30ec0f24c38f	4671b7aa-800a-4ee9-9229-a39d3e6230fb	e0219d86-839f-447a-a310-4a7cc34af686	2	\N
a589b4db-2987-4739-bca6-277a59b4ff30	4671b7aa-800a-4ee9-9229-a39d3e6230fb	37c642e6-ec0f-4011-afd8-0d2bb77411a3	1	\N
0439cce4-afe1-45a0-9c92-4969fb5a3935	4671b7aa-800a-4ee9-9229-a39d3e6230fb	326bd3ae-1b5f-47b1-853f-1516a7182669	0	\N
085cd7d9-9a9a-42b9-a92e-22aa0bee8750	4671b7aa-800a-4ee9-9229-a39d3e6230fb	bab68678-edd4-4485-8d72-ae998cdf02d0	2	\N
cdac85dd-617e-41b1-b835-9628d3c76a73	4671b7aa-800a-4ee9-9229-a39d3e6230fb	f60c4cac-9215-452f-bcee-446724b4c5df	1	\N
d0be1cb3-b123-45d5-ba38-396139663c4a	4671b7aa-800a-4ee9-9229-a39d3e6230fb	8114e989-f75e-43a0-9925-eb66ea58e908	1	\N
19928728-a7bd-4705-8068-2df4494084c3	4671b7aa-800a-4ee9-9229-a39d3e6230fb	2d294931-dfb0-4ab3-a453-93c8b791d853	1	\N
926faf10-25d7-48c4-b19b-2dc622c7e57a	4671b7aa-800a-4ee9-9229-a39d3e6230fb	99094616-1233-481d-be5f-d59fc0e8b3ee	2	\N
83cf2cdb-3862-4239-95e2-a57aadea7b7e	4671b7aa-800a-4ee9-9229-a39d3e6230fb	56fbc3fc-0d8b-4e53-bc71-f16dff24d03f	2	\N
02dae392-8d1d-479a-a6f5-2bc6e35d347a	4671b7aa-800a-4ee9-9229-a39d3e6230fb	7130dde9-c15e-462d-9384-b560e1b10693	1	\N
0c585dfa-5097-4050-bbd3-724872fce7a7	4671b7aa-800a-4ee9-9229-a39d3e6230fb	c1f28dd0-c438-49da-b093-f27a29a4fbe4	2	\N
36b38fe7-f31f-43e7-a2f1-bc566bec35a9	4671b7aa-800a-4ee9-9229-a39d3e6230fb	3297f494-5c84-4607-a9c7-0cd373202fb7	0	\N
b87b5076-e750-4059-b8da-cb091a5e4160	4671b7aa-800a-4ee9-9229-a39d3e6230fb	c19cafba-aeb4-4a0c-99b2-cf4a84880394	1	\N
55a466cf-8e0c-4980-806c-c68136828bf5	4671b7aa-800a-4ee9-9229-a39d3e6230fb	c976199c-dc57-4144-9b8a-811380ecde1b	1	\N
3c9836f4-4b65-4612-b923-beef1ce31e81	4671b7aa-800a-4ee9-9229-a39d3e6230fb	88a9cae7-4199-4255-84bb-918efee13770	2	\N
1c5dbec7-8144-47d4-ba1e-58c0b1f3342d	4671b7aa-800a-4ee9-9229-a39d3e6230fb	f762ddee-2a3b-4d4b-aa3d-d404e517fa69	1	\N
29f0845a-ebca-4f80-806f-e388f682ab86	4671b7aa-800a-4ee9-9229-a39d3e6230fb	7c8a5806-8bf0-4872-a69b-61dcc97a46a6	1	\N
0dc504dc-b850-4c96-b7eb-87b39a471d7b	4671b7aa-800a-4ee9-9229-a39d3e6230fb	d6c128a2-99da-4d80-937c-f684983e5171	0	\N
9e3221ec-eb49-402d-aab0-83c46d9ebcd5	4671b7aa-800a-4ee9-9229-a39d3e6230fb	e2a958ad-948b-4862-b15c-b2145ef2a440	1	\N
9341bbcb-2177-4e36-8daa-0a01a957bbe9	4671b7aa-800a-4ee9-9229-a39d3e6230fb	e679ba89-1ef1-472f-b524-858c00d5ac2d	2	\N
785751b6-fb87-422e-a516-d873d04a7203	c2e066ce-5cc2-47ff-9f3f-5c95949fdd74	be7340fc-7ef9-47fb-9ee6-66e8bdf4528a	1	\N
68ef4214-0e22-46a1-8af9-5b147da640ec	4671b7aa-800a-4ee9-9229-a39d3e6230fb	6f57f38f-f572-49af-9758-26d6e57a5746	2	\N
0757205d-1e3d-4bdf-8767-cdc9079637b8	c2e066ce-5cc2-47ff-9f3f-5c95949fdd74	d0cdaa45-472a-401d-ab1d-6c9628afc382	1	\N
6ef71cae-23eb-4f02-8620-9c9e583219ab	4671b7aa-800a-4ee9-9229-a39d3e6230fb	d0c602c2-6839-4e42-848e-959de7613821	2	\N
b8ec4a34-187f-4707-8b4b-c218593589e0	4671b7aa-800a-4ee9-9229-a39d3e6230fb	a5d9f334-465d-4f30-8e49-1de5a588dd7e	2	\N
f4e9be36-af7e-4229-b6a0-047e2f836c45	4671b7aa-800a-4ee9-9229-a39d3e6230fb	68fdc69d-6b79-45c5-ab30-30e1aefdafa4	2	\N
8f216846-b696-4ce3-9a1a-a82e28837612	4671b7aa-800a-4ee9-9229-a39d3e6230fb	e6a47da4-51ad-465c-bd95-4309370ee6b1	2	\N
aab9e2dd-1bb4-4c3f-98d5-47ea787af3dd	c2e066ce-5cc2-47ff-9f3f-5c95949fdd74	6e7aaf17-cee5-41ac-8637-0dca686d1f72	1	\N
993c9e3a-b62b-4957-bff2-4ba6efc65618	4671b7aa-800a-4ee9-9229-a39d3e6230fb	846e69cc-27e8-4308-9288-87c02b34d4a3	2	\N
ac8a6e0a-add2-43eb-8207-c8481cc37b2a	4671b7aa-800a-4ee9-9229-a39d3e6230fb	7c34f4cf-f819-45a1-89e2-390cab528977	2	\N
718d9b40-c910-4862-969a-1f099f72b9e1	4671b7aa-800a-4ee9-9229-a39d3e6230fb	e1a3727c-1f71-4b07-80eb-31b202f61908	0	\N
69f9abaa-8823-4f4c-9676-f8421998981a	4671b7aa-800a-4ee9-9229-a39d3e6230fb	98dc56aa-2b01-4639-aa73-ab9b865e272d	0	\N
b92ec39d-206b-4349-9d17-777ed29b82e1	26eb2041-66e6-485b-bdfb-20c9d9e623aa	6e7aaf17-cee5-41ac-8637-0dca686d1f72	2	\N
8bfbad06-193a-43e7-8d63-79a97d9d4284	c2e066ce-5cc2-47ff-9f3f-5c95949fdd74	4198b0fc-8c96-4f3f-a538-d34b39045cdf	1	\N
b56c3eb4-7fd4-4c2e-a140-b983d3c8deae	4671b7aa-800a-4ee9-9229-a39d3e6230fb	5faeffea-c30f-4bee-aca3-630b3ba24377	0	\N
8059363a-1028-4477-868b-53327c6aca5a	4671b7aa-800a-4ee9-9229-a39d3e6230fb	becc9d63-42d7-4fbf-b833-49a7c244520d	1	\N
e21bc94e-1ba1-4665-9041-5b03d6515054	c2e066ce-5cc2-47ff-9f3f-5c95949fdd74	b2d60abd-bf77-4f16-be34-3f5b62352885	2	\N
a215aac0-fa15-4fe0-8eb0-e014f4146184	c2e066ce-5cc2-47ff-9f3f-5c95949fdd74	fed9b0f1-374f-443d-93b8-a68cfef0f8d0	2	\N
c824a815-fc08-45f3-a8de-4e33d8b504df	c2e066ce-5cc2-47ff-9f3f-5c95949fdd74	4568ab20-a2ce-4cfa-91cd-9f4a1de997de	1	\N
9512a6c9-5d99-46a0-819b-3a0314490a04	4671b7aa-800a-4ee9-9229-a39d3e6230fb	99de9373-47b9-4267-9741-de7b79d4f344	1	\N
9a67c0c1-96b8-4b81-b05e-cc5454dd4483	4671b7aa-800a-4ee9-9229-a39d3e6230fb	2d58fa47-92c7-4635-a06f-48b23e7ca061	2	\N
fe6d0663-136d-4aef-b2ed-4a2ad465f6e7	c2e066ce-5cc2-47ff-9f3f-5c95949fdd74	21149ade-6555-4c27-a52f-3969e568354e	0	\N
113a246d-fde2-4453-a8de-6f0bd2833550	c2e066ce-5cc2-47ff-9f3f-5c95949fdd74	bab68678-edd4-4485-8d72-ae998cdf02d0	2	\N
5d20d926-6e7f-468a-b4fb-443cbc53235d	4671b7aa-800a-4ee9-9229-a39d3e6230fb	dc1436c8-09d6-4c1d-b8b4-b71e501a6621	2	\N
a55092a0-1c7d-435c-a1b5-c4b95396759a	c2e066ce-5cc2-47ff-9f3f-5c95949fdd74	c4b8d77b-797f-49b6-9ea8-7717d095997a	1	\N
ea0f6000-3e0e-4307-a227-d2c233a2cd3d	c2e066ce-5cc2-47ff-9f3f-5c95949fdd74	8079ef20-ca48-413d-abff-9bddd3ad7379	1	\N
498ca951-783a-4b21-abd0-ec35eaae9282	c2e066ce-5cc2-47ff-9f3f-5c95949fdd74	d131b6cc-e56f-42ef-a9ee-f12bb1059ac5	1	\N
31e6d8e3-62dc-41d7-bd11-e312a287efbe	c2e066ce-5cc2-47ff-9f3f-5c95949fdd74	4bddca33-9207-4b6c-a284-23e7fc1f8beb	1	\N
963588e2-5888-4e07-bc05-a3c5e3ee2f57	c2e066ce-5cc2-47ff-9f3f-5c95949fdd74	3eccc514-0bed-40c4-ac6d-84741b75ee0f	0	\N
6b513654-743d-4209-a70c-4f83f6c52e42	c2e066ce-5cc2-47ff-9f3f-5c95949fdd74	a5ebb569-491e-4f0c-9198-74711d119edc	0	\N
de43cd55-8e58-43cb-a806-d5e45d16f7f5	c2e066ce-5cc2-47ff-9f3f-5c95949fdd74	9a2d4ac0-c0ab-4e3a-a8d3-f0e184ef3d21	2	\N
1cff44c3-dc1e-4c98-917e-864c4be9b653	c2e066ce-5cc2-47ff-9f3f-5c95949fdd74	37c642e6-ec0f-4011-afd8-0d2bb77411a3	2	\N
9055b78e-8556-4702-bf92-82976ac94b28	c2e066ce-5cc2-47ff-9f3f-5c95949fdd74	326bd3ae-1b5f-47b1-853f-1516a7182669	2	\N
f3cc2af1-b61e-4e7a-b722-ebf5bfc90e80	c2e066ce-5cc2-47ff-9f3f-5c95949fdd74	e679ba89-1ef1-472f-b524-858c00d5ac2d	2	\N
4098b96c-a664-4c11-ab78-24189b4a2fa3	c2e066ce-5cc2-47ff-9f3f-5c95949fdd74	a5d9f334-465d-4f30-8e49-1de5a588dd7e	2	\N
d500ba00-af75-4fa1-b138-87a74eaaef7a	26eb2041-66e6-485b-bdfb-20c9d9e623aa	1459c1e8-4c40-42aa-bc76-719365d9b84f	0	\N
bcef0a4a-70dc-46f0-a723-740705dae274	26eb2041-66e6-485b-bdfb-20c9d9e623aa	4198b0fc-8c96-4f3f-a538-d34b39045cdf	2	\N
5bed4b2b-06ab-4a6c-8e49-6b8c4c5b3ee6	26eb2041-66e6-485b-bdfb-20c9d9e623aa	8114e989-f75e-43a0-9925-eb66ea58e908	1	\N
4a34ac1f-f73a-49a8-a01f-dbbfc302fd02	26eb2041-66e6-485b-bdfb-20c9d9e623aa	9bf793be-ca7b-4d9d-97d7-59de82bffc28	2	\N
6ce58eab-74c1-4ff3-a9cb-32734b31c7e8	26eb2041-66e6-485b-bdfb-20c9d9e623aa	e2a958ad-948b-4862-b15c-b2145ef2a440	2	\N
476a963f-c3c1-4bde-b974-5d0119cbf1ad	26eb2041-66e6-485b-bdfb-20c9d9e623aa	846e69cc-27e8-4308-9288-87c02b34d4a3	2	\N
f5f63367-fad6-4e28-8875-2822b7834c9a	58855f44-a4f1-4a33-b446-63936dd87231	3297f494-5c84-4607-a9c7-0cd373202fb7	\N	\N
56fec1b2-9a97-4360-a038-08771eeb3f8b	58855f44-a4f1-4a33-b446-63936dd87231	326bd3ae-1b5f-47b1-853f-1516a7182669	2	\N
7b1bb6ed-4368-49c1-a3ec-88881b7001ff	58855f44-a4f1-4a33-b446-63936dd87231	02b972ab-70b6-43a4-8c52-97459d560128	0	\N
d46e1c75-1014-4504-9de9-91a6204d5169	58855f44-a4f1-4a33-b446-63936dd87231	f60c4cac-9215-452f-bcee-446724b4c5df	1	\N
ae38650e-bddf-4c3e-9725-78e9592e33d6	58855f44-a4f1-4a33-b446-63936dd87231	c19cafba-aeb4-4a0c-99b2-cf4a84880394	1	\N
3730ecd6-584f-4cb6-8198-46ba257197ea	58855f44-a4f1-4a33-b446-63936dd87231	9bf793be-ca7b-4d9d-97d7-59de82bffc28	0	\N
6d4a5e43-ea73-4fd0-a458-c78eb19f3f7b	58855f44-a4f1-4a33-b446-63936dd87231	f762ddee-2a3b-4d4b-aa3d-d404e517fa69	\N	\N
e015bf5f-0ce3-471f-ac6e-456bd7e532f9	58855f44-a4f1-4a33-b446-63936dd87231	0ba08c51-4ea3-4b96-b210-689f33edf0ff	\N	\N
e00f7c07-7071-4574-9a62-64d08248b047	47f4b7fe-8642-4a38-a1d3-dab378b302d7	9bf793be-ca7b-4d9d-97d7-59de82bffc28	\N	\N
739b911b-d967-49f5-a44c-76e1120d19e6	47f4b7fe-8642-4a38-a1d3-dab378b302d7	02b972ab-70b6-43a4-8c52-97459d560128	\N	\N
8b7e2eb1-2dfd-4e22-81f5-3d6f1b96b36e	47f4b7fe-8642-4a38-a1d3-dab378b302d7	7aa1739e-1dd3-4ea5-8d82-ac738f77a9a3	\N	\N
32c498a5-7752-4f49-a1de-a603f1d1bae8	47f4b7fe-8642-4a38-a1d3-dab378b302d7	714354ab-5a24-448f-805b-05c846c13597	\N	\N
db755ca5-feed-4ccf-8251-a98c20f39029	47f4b7fe-8642-4a38-a1d3-dab378b302d7	4568ab20-a2ce-4cfa-91cd-9f4a1de997de	0	\N
ca952891-895a-49e0-bf39-236a8e6e54c0	47f4b7fe-8642-4a38-a1d3-dab378b302d7	fed9b0f1-374f-443d-93b8-a68cfef0f8d0	0	\N
8b9a4fb4-777a-43c2-8ed2-0c215cf50914	47f4b7fe-8642-4a38-a1d3-dab378b302d7	21149ade-6555-4c27-a52f-3969e568354e	1	\N
26826934-0f15-4f62-8b03-600e0fa2c8e6	47f4b7fe-8642-4a38-a1d3-dab378b302d7	d131b6cc-e56f-42ef-a9ee-f12bb1059ac5	0	\N
a6ea52b3-20a5-4053-bd55-946fb85df180	47f4b7fe-8642-4a38-a1d3-dab378b302d7	3eccc514-0bed-40c4-ac6d-84741b75ee0f	0	\N
8ad6a763-8f2e-4079-8e46-d0bec0ed2f6a	47f4b7fe-8642-4a38-a1d3-dab378b302d7	1459c1e8-4c40-42aa-bc76-719365d9b84f	2	\N
2cf53212-ec72-414e-a66f-1d57c4239bb0	47f4b7fe-8642-4a38-a1d3-dab378b302d7	bab68678-edd4-4485-8d72-ae998cdf02d0	2	\N
396a0605-e658-4945-bb69-4a75df780c51	47f4b7fe-8642-4a38-a1d3-dab378b302d7	0ac60ce0-9b6b-457e-ab20-1c4d3e6b8164	1	\N
db3e448f-c708-4067-860f-b09d0fdc3ece	47f4b7fe-8642-4a38-a1d3-dab378b302d7	a5ebb569-491e-4f0c-9198-74711d119edc	1	\N
20133110-6381-4c93-98e9-7a77541c53a7	47f4b7fe-8642-4a38-a1d3-dab378b302d7	4198b0fc-8c96-4f3f-a538-d34b39045cdf	1	\N
a1c2fc21-31e5-4f40-8b5e-5fd1910bd27e	47f4b7fe-8642-4a38-a1d3-dab378b302d7	8ed3ffcc-3b59-47bf-9de4-36224220edc0	1	\N
82eff081-3b14-4dcf-8292-f7d7c9c10dc0	47f4b7fe-8642-4a38-a1d3-dab378b302d7	b5bacf10-72cd-4499-87e1-7acd901f0eba	1	\N
9a7d62b1-3e6e-4403-82d3-ed12c6ef2925	47f4b7fe-8642-4a38-a1d3-dab378b302d7	e0219d86-839f-447a-a310-4a7cc34af686	1	\N
fed86d74-2ab5-42e1-a3f9-1b0cbfdf8eba	47f4b7fe-8642-4a38-a1d3-dab378b302d7	37c642e6-ec0f-4011-afd8-0d2bb77411a3	1	\N
90ecf214-eba1-4e4a-b066-fa41beee7eae	47f4b7fe-8642-4a38-a1d3-dab378b302d7	f60c4cac-9215-452f-bcee-446724b4c5df	2	\N
0cbb0cd7-04fe-47cb-bc13-ed031dd379ae	47f4b7fe-8642-4a38-a1d3-dab378b302d7	8114e989-f75e-43a0-9925-eb66ea58e908	2	\N
5f1c7c45-f13e-4c66-9f11-b2d7436dbaa5	47f4b7fe-8642-4a38-a1d3-dab378b302d7	2d294931-dfb0-4ab3-a453-93c8b791d853	2	\N
ab9cd6de-77b7-407a-9d5b-f968fd91e038	47f4b7fe-8642-4a38-a1d3-dab378b302d7	99094616-1233-481d-be5f-d59fc0e8b3ee	2	\N
2f23b774-3b78-4be8-b17b-a654fd99e8a2	47f4b7fe-8642-4a38-a1d3-dab378b302d7	56fbc3fc-0d8b-4e53-bc71-f16dff24d03f	2	\N
18fb8378-a36c-4037-a3d3-fa33a9a0ddf0	47f4b7fe-8642-4a38-a1d3-dab378b302d7	c976199c-dc57-4144-9b8a-811380ecde1b	2	\N
bc1806ce-19dd-454f-8250-c73ef43c3058	47f4b7fe-8642-4a38-a1d3-dab378b302d7	7130dde9-c15e-462d-9384-b560e1b10693	1	\N
a0a7605a-e6e2-450c-be00-6ab94636e0bf	47f4b7fe-8642-4a38-a1d3-dab378b302d7	c19cafba-aeb4-4a0c-99b2-cf4a84880394	2	\N
d062d8f4-7c44-4049-8d24-c044c1466c32	47f4b7fe-8642-4a38-a1d3-dab378b302d7	3297f494-5c84-4607-a9c7-0cd373202fb7	2	\N
0da1f9b6-da92-47e5-99b8-42840153fcbb	47f4b7fe-8642-4a38-a1d3-dab378b302d7	88a9cae7-4199-4255-84bb-918efee13770	2	\N
6abac51b-b9e2-4b09-91b0-5e0614d31317	47f4b7fe-8642-4a38-a1d3-dab378b302d7	14f29127-0c8b-4ec4-a7fa-f746ce8fa750	0	\N
713185f7-29db-42ae-8871-e0466abbf3c0	47f4b7fe-8642-4a38-a1d3-dab378b302d7	f762ddee-2a3b-4d4b-aa3d-d404e517fa69	1	\N
c4660235-c5af-4f54-9539-fbdce6312898	47f4b7fe-8642-4a38-a1d3-dab378b302d7	7c8a5806-8bf0-4872-a69b-61dcc97a46a6	2	\N
76418fe3-daf1-48de-978b-e1a229ab1986	47f4b7fe-8642-4a38-a1d3-dab378b302d7	df93db84-806c-4a93-99ed-c4ce6a35da56	2	\N
7f646736-b19b-4f06-b1c8-d562eab40940	47f4b7fe-8642-4a38-a1d3-dab378b302d7	d6c128a2-99da-4d80-937c-f684983e5171	2	\N
d12a17f9-7d26-4062-800f-3b19287783bd	47f4b7fe-8642-4a38-a1d3-dab378b302d7	e2a958ad-948b-4862-b15c-b2145ef2a440	2	\N
84c05f58-fee6-4618-8cf2-9daf2eacaa85	47f4b7fe-8642-4a38-a1d3-dab378b302d7	e679ba89-1ef1-472f-b524-858c00d5ac2d	2	\N
5fe190b1-593a-446f-bf7e-2d60da75fcd8	47f4b7fe-8642-4a38-a1d3-dab378b302d7	d0c602c2-6839-4e42-848e-959de7613821	2	\N
a68e9cd3-8801-4951-8f03-6701fbbae28d	47f4b7fe-8642-4a38-a1d3-dab378b302d7	e1a3727c-1f71-4b07-80eb-31b202f61908	0	\N
62718c63-3560-4e91-8747-4b0c628348ef	47f4b7fe-8642-4a38-a1d3-dab378b302d7	7c34f4cf-f819-45a1-89e2-390cab528977	1	\N
bb19fa23-88b2-4bd4-ae38-ac5cdf02ab25	47f4b7fe-8642-4a38-a1d3-dab378b302d7	98dc56aa-2b01-4639-aa73-ab9b865e272d	0	\N
e8800e50-8507-40a3-b58b-b0e388d9ac56	47f4b7fe-8642-4a38-a1d3-dab378b302d7	becc9d63-42d7-4fbf-b833-49a7c244520d	0	\N
a0083c78-c28d-4216-8eae-330198bcae87	58855f44-a4f1-4a33-b446-63936dd87231	4568ab20-a2ce-4cfa-91cd-9f4a1de997de	1	\N
8f6871a6-19aa-4ce8-b0c1-774409eaa83f	47f4b7fe-8642-4a38-a1d3-dab378b302d7	a5d9f334-465d-4f30-8e49-1de5a588dd7e	1	\N
7e7ac70a-3aa6-46e0-9c28-b3f9a96db5ff	47f4b7fe-8642-4a38-a1d3-dab378b302d7	6f57f38f-f572-49af-9758-26d6e57a5746	1	\N
47764350-1249-42db-86fa-f166164f5c65	47f4b7fe-8642-4a38-a1d3-dab378b302d7	2d58fa47-92c7-4635-a06f-48b23e7ca061	1	\N
09b13fd5-e0c2-4671-b891-c95bb76e6894	47f4b7fe-8642-4a38-a1d3-dab378b302d7	dc1436c8-09d6-4c1d-b8b4-b71e501a6621	1	\N
9f3fa4b4-0519-4433-a942-3c4e69c165bd	47f4b7fe-8642-4a38-a1d3-dab378b302d7	99de9373-47b9-4267-9741-de7b79d4f344	1	\N
9c8fab72-755a-4746-80f0-d4791d73c257	47f4b7fe-8642-4a38-a1d3-dab378b302d7	68fdc69d-6b79-45c5-ab30-30e1aefdafa4	1	\N
4e74f93e-d5a4-4d5a-9f19-450fb88298b6	47f4b7fe-8642-4a38-a1d3-dab378b302d7	5faeffea-c30f-4bee-aca3-630b3ba24377	1	\N
9da54124-e5d7-46f6-8a6f-db877f22f799	58855f44-a4f1-4a33-b446-63936dd87231	6e7aaf17-cee5-41ac-8637-0dca686d1f72	2	\N
2d6abae2-56b9-4f7d-b677-c2df9adadd8d	58855f44-a4f1-4a33-b446-63936dd87231	21149ade-6555-4c27-a52f-3969e568354e	2	\N
ae499a56-fead-4876-8054-af154e60b7b0	58855f44-a4f1-4a33-b446-63936dd87231	c4b8d77b-797f-49b6-9ea8-7717d095997a	2	\N
7415002b-1fdb-4036-92b6-c1738a5ed800	58855f44-a4f1-4a33-b446-63936dd87231	8079ef20-ca48-413d-abff-9bddd3ad7379	2	\N
c4635f51-0d00-4b7d-b425-a5ff8c065fe1	58855f44-a4f1-4a33-b446-63936dd87231	714354ab-5a24-448f-805b-05c846c13597	2	\N
fc374ab0-0a85-4fcd-becc-380f11b42a85	58855f44-a4f1-4a33-b446-63936dd87231	fed9b0f1-374f-443d-93b8-a68cfef0f8d0	2	\N
3fa819cc-d8e1-471d-aa58-01487583d47e	58855f44-a4f1-4a33-b446-63936dd87231	4bddca33-9207-4b6c-a284-23e7fc1f8beb	0	\N
23793d7a-eb02-4ace-96db-dc8903931e6d	58855f44-a4f1-4a33-b446-63936dd87231	d131b6cc-e56f-42ef-a9ee-f12bb1059ac5	1	\N
1ac0a511-40a3-4102-bb48-a2a82d2fbed9	58855f44-a4f1-4a33-b446-63936dd87231	3eccc514-0bed-40c4-ac6d-84741b75ee0f	0	\N
39526e7e-34d7-4876-90f8-022004291084	58855f44-a4f1-4a33-b446-63936dd87231	1459c1e8-4c40-42aa-bc76-719365d9b84f	0	\N
e82d781a-0eb2-4943-92a9-fa8572118824	58855f44-a4f1-4a33-b446-63936dd87231	0ac60ce0-9b6b-457e-ab20-1c4d3e6b8164	0	\N
0c48b714-032c-4e0f-838c-cefc33d0f2bb	58855f44-a4f1-4a33-b446-63936dd87231	a5ebb569-491e-4f0c-9198-74711d119edc	0	\N
bfefa27b-c362-47a2-9843-858dc72c51b4	58855f44-a4f1-4a33-b446-63936dd87231	8ed3ffcc-3b59-47bf-9de4-36224220edc0	0	\N
f7ac456b-f1ff-4960-8aa6-5b91d5291f28	58855f44-a4f1-4a33-b446-63936dd87231	4198b0fc-8c96-4f3f-a538-d34b39045cdf	1	\N
b833803f-ccfe-44cd-b51f-3d35203be6af	58855f44-a4f1-4a33-b446-63936dd87231	b5bacf10-72cd-4499-87e1-7acd901f0eba	0	\N
fd180f79-44f0-4441-a5cb-f6d2eb5892c4	58855f44-a4f1-4a33-b446-63936dd87231	9a2d4ac0-c0ab-4e3a-a8d3-f0e184ef3d21	0	\N
005d075c-8150-46d6-a945-ffe4cac00b50	58855f44-a4f1-4a33-b446-63936dd87231	bab68678-edd4-4485-8d72-ae998cdf02d0	2	\N
eceb9558-aab3-4748-9704-00282edf1feb	58855f44-a4f1-4a33-b446-63936dd87231	8114e989-f75e-43a0-9925-eb66ea58e908	0	\N
7ab718fe-a809-4701-b98c-a6208da982da	58855f44-a4f1-4a33-b446-63936dd87231	2d294931-dfb0-4ab3-a453-93c8b791d853	0	\N
b1af284f-f0ee-40ad-b13f-2961ecf68e0c	58855f44-a4f1-4a33-b446-63936dd87231	56fbc3fc-0d8b-4e53-bc71-f16dff24d03f	0	\N
26c19fba-0114-440c-92e4-4d59b03f7871	58855f44-a4f1-4a33-b446-63936dd87231	7130dde9-c15e-462d-9384-b560e1b10693	2	\N
055be282-6c07-4976-97a6-ee9d9159eb39	58855f44-a4f1-4a33-b446-63936dd87231	88a9cae7-4199-4255-84bb-918efee13770	0	\N
721912e8-fe2f-48f0-8492-d79ab794551f	58855f44-a4f1-4a33-b446-63936dd87231	c1f28dd0-c438-49da-b093-f27a29a4fbe4	1	\N
606e3603-7434-42d4-b745-6812b6167b84	58855f44-a4f1-4a33-b446-63936dd87231	c976199c-dc57-4144-9b8a-811380ecde1b	1	\N
6b69bf1c-9635-40b9-8f12-6b9e00a314b6	58855f44-a4f1-4a33-b446-63936dd87231	14f29127-0c8b-4ec4-a7fa-f746ce8fa750	0	\N
4d9a3683-8c1e-46f6-b513-a5487c85db9e	58855f44-a4f1-4a33-b446-63936dd87231	7c8a5806-8bf0-4872-a69b-61dcc97a46a6	2	\N
b95a62c9-b4bf-4b49-8c23-f83d77681082	58855f44-a4f1-4a33-b446-63936dd87231	df93db84-806c-4a93-99ed-c4ce6a35da56	2	\N
f09da324-0762-4c92-93e6-8ad913be4528	58855f44-a4f1-4a33-b446-63936dd87231	d6c128a2-99da-4d80-937c-f684983e5171	2	\N
c7e200d9-f91f-49dd-9d5a-6c97ea3023db	58855f44-a4f1-4a33-b446-63936dd87231	e2a958ad-948b-4862-b15c-b2145ef2a440	2	\N
9d715d63-cdbe-4029-abc3-384c2f03ca98	58855f44-a4f1-4a33-b446-63936dd87231	e6a47da4-51ad-465c-bd95-4309370ee6b1	0	\N
6cb43a22-17fc-4aed-9d13-c8882d4c99b9	58855f44-a4f1-4a33-b446-63936dd87231	d0c602c2-6839-4e42-848e-959de7613821	0	\N
293ac216-fb17-42c2-9067-098c13bb89e4	58855f44-a4f1-4a33-b446-63936dd87231	7c34f4cf-f819-45a1-89e2-390cab528977	0	\N
d3d52919-f415-4ff1-b7dd-1fe43e54107c	58855f44-a4f1-4a33-b446-63936dd87231	e1a3727c-1f71-4b07-80eb-31b202f61908	0	\N
a7a49f5e-4489-40bd-b809-074cc4b49358	58855f44-a4f1-4a33-b446-63936dd87231	dc1436c8-09d6-4c1d-b8b4-b71e501a6621	0	\N
4497eec0-3073-44ba-bc2f-ccd0a754aa55	58855f44-a4f1-4a33-b446-63936dd87231	98dc56aa-2b01-4639-aa73-ab9b865e272d	1	\N
f2506aa0-7133-4c5b-85ad-d82b21368740	58855f44-a4f1-4a33-b446-63936dd87231	becc9d63-42d7-4fbf-b833-49a7c244520d	1	\N
cead83fa-79dd-471f-9c47-a613bf547f14	58855f44-a4f1-4a33-b446-63936dd87231	a5d9f334-465d-4f30-8e49-1de5a588dd7e	0	\N
79199d5e-0053-4731-9414-bf112b71fa6b	58855f44-a4f1-4a33-b446-63936dd87231	846e69cc-27e8-4308-9288-87c02b34d4a3	1	\N
4318f3ba-72f6-4866-bd8a-925c37a93554	58855f44-a4f1-4a33-b446-63936dd87231	2d58fa47-92c7-4635-a06f-48b23e7ca061	1	\N
ce348002-3db1-4f61-8402-74dd7ef5a180	58855f44-a4f1-4a33-b446-63936dd87231	99de9373-47b9-4267-9741-de7b79d4f344	0	\N
a5f74444-ab4a-4cbd-bc2d-ccf7a5fe5d24	58855f44-a4f1-4a33-b446-63936dd87231	68fdc69d-6b79-45c5-ab30-30e1aefdafa4	1	\N
8ed65a95-c15f-459e-ba87-7c5c90be581b	47f4b7fe-8642-4a38-a1d3-dab378b302d7	4bddca33-9207-4b6c-a284-23e7fc1f8beb	\N	\N
01c0ccd2-3e49-4f65-8b61-6d1f823871c2	8f9d8a5d-9fac-4975-91bb-b8ee5aa03130	6e7aaf17-cee5-41ac-8637-0dca686d1f72	1	\N
31ad96ed-9e33-40cc-afb0-043006770d56	8f9d8a5d-9fac-4975-91bb-b8ee5aa03130	0ba08c51-4ea3-4b96-b210-689f33edf0ff	2	\N
5d7979e6-31fe-4e72-9fa6-302484b66a6c	8f9d8a5d-9fac-4975-91bb-b8ee5aa03130	a5ebb569-491e-4f0c-9198-74711d119edc	1	\N
bffc8923-ddf6-4b12-a533-df6b3612b2fc	8f9d8a5d-9fac-4975-91bb-b8ee5aa03130	b2d60abd-bf77-4f16-be34-3f5b62352885	2	\N
da313f0d-bd50-40ae-9561-3acf79fb6390	8f9d8a5d-9fac-4975-91bb-b8ee5aa03130	4568ab20-a2ce-4cfa-91cd-9f4a1de997de	0	\N
20efa782-9d42-40b7-aeec-7158269905bf	8f9d8a5d-9fac-4975-91bb-b8ee5aa03130	21149ade-6555-4c27-a52f-3969e568354e	0	\N
749bcf7f-6c9b-4e18-b0e7-5df7177aeb02	8f9d8a5d-9fac-4975-91bb-b8ee5aa03130	c4b8d77b-797f-49b6-9ea8-7717d095997a	0	\N
e05531b2-ccbe-4173-a36b-ada4cc2a5212	8f9d8a5d-9fac-4975-91bb-b8ee5aa03130	8079ef20-ca48-413d-abff-9bddd3ad7379	0	\N
4f909625-3d1e-4517-a346-627270b09037	8f9d8a5d-9fac-4975-91bb-b8ee5aa03130	714354ab-5a24-448f-805b-05c846c13597	0	\N
98c71810-2710-43e7-85c7-d702f7e15b01	8f9d8a5d-9fac-4975-91bb-b8ee5aa03130	99094616-1233-481d-be5f-d59fc0e8b3ee	1	\N
e2623958-857e-4c50-91b9-665ad0fe7cbf	8f9d8a5d-9fac-4975-91bb-b8ee5aa03130	be7340fc-7ef9-47fb-9ee6-66e8bdf4528a	1	\N
42d643c0-18a1-44a9-8923-8623c15ac646	8f9d8a5d-9fac-4975-91bb-b8ee5aa03130	d0cdaa45-472a-401d-ab1d-6c9628afc382	2	\N
83182b68-e002-417e-bac2-3ee69ef40445	8f9d8a5d-9fac-4975-91bb-b8ee5aa03130	4198b0fc-8c96-4f3f-a538-d34b39045cdf	1	\N
16a6549e-afe1-40eb-b82b-16646a7d8b91	8f9d8a5d-9fac-4975-91bb-b8ee5aa03130	fed9b0f1-374f-443d-93b8-a68cfef0f8d0	2	\N
a4316e80-ed06-4956-83e1-c52d541fc0e9	8f9d8a5d-9fac-4975-91bb-b8ee5aa03130	56fbc3fc-0d8b-4e53-bc71-f16dff24d03f	1	\N
f29f781f-c3cb-4e2d-850f-3f4ec6385382	8f9d8a5d-9fac-4975-91bb-b8ee5aa03130	8ed3ffcc-3b59-47bf-9de4-36224220edc0	1	\N
897a89a5-207b-4318-aaf5-a3edbe41d7fa	8f9d8a5d-9fac-4975-91bb-b8ee5aa03130	d131b6cc-e56f-42ef-a9ee-f12bb1059ac5	2	\N
03353d4f-6c9c-424d-baa3-30bcf77aef6c	8f9d8a5d-9fac-4975-91bb-b8ee5aa03130	7c8a5806-8bf0-4872-a69b-61dcc97a46a6	1	\N
3265ce12-6ddb-4f54-b091-d148c08d22e2	8f9d8a5d-9fac-4975-91bb-b8ee5aa03130	b5bacf10-72cd-4499-87e1-7acd901f0eba	1	\N
ee9617ed-4fce-41ce-b295-d58d82506a6c	8f9d8a5d-9fac-4975-91bb-b8ee5aa03130	4bddca33-9207-4b6c-a284-23e7fc1f8beb	2	\N
e6012038-6c5b-4804-8bf3-d81187c28482	8f9d8a5d-9fac-4975-91bb-b8ee5aa03130	7130dde9-c15e-462d-9384-b560e1b10693	1	\N
44a762c9-b160-4fa7-a3aa-b1d9779b0816	8f9d8a5d-9fac-4975-91bb-b8ee5aa03130	9a2d4ac0-c0ab-4e3a-a8d3-f0e184ef3d21	1	\N
be73e4a8-a9f6-4fc6-ac43-a57a1ad88e66	8f9d8a5d-9fac-4975-91bb-b8ee5aa03130	e0219d86-839f-447a-a310-4a7cc34af686	0	\N
4f7e1fd2-ae8a-4b98-ab24-1d8a31298f12	8f9d8a5d-9fac-4975-91bb-b8ee5aa03130	3eccc514-0bed-40c4-ac6d-84741b75ee0f	1	\N
88319fb5-38e0-42f1-b61b-47df17a46737	8f9d8a5d-9fac-4975-91bb-b8ee5aa03130	c1f28dd0-c438-49da-b093-f27a29a4fbe4	0	\N
13e8422f-ace8-4997-b08c-015b9c80b0a0	8f9d8a5d-9fac-4975-91bb-b8ee5aa03130	1459c1e8-4c40-42aa-bc76-719365d9b84f	1	\N
65ed3ade-99bd-4482-987a-811c196eb980	8f9d8a5d-9fac-4975-91bb-b8ee5aa03130	37c642e6-ec0f-4011-afd8-0d2bb77411a3	1	\N
c88a5f8f-f1b9-4cbd-b702-2865f1dde3e1	8f9d8a5d-9fac-4975-91bb-b8ee5aa03130	0ac60ce0-9b6b-457e-ab20-1c4d3e6b8164	1	\N
fd0fd9e2-eaa6-4ce6-b1ff-37128efac9bc	8f9d8a5d-9fac-4975-91bb-b8ee5aa03130	c976199c-dc57-4144-9b8a-811380ecde1b	0	\N
d55be2b5-4ebb-4f36-9c78-0fa1252f0265	8f9d8a5d-9fac-4975-91bb-b8ee5aa03130	326bd3ae-1b5f-47b1-853f-1516a7182669	1	\N
e4b13739-bb01-4af7-8eb4-4856c77791f6	8f9d8a5d-9fac-4975-91bb-b8ee5aa03130	c19cafba-aeb4-4a0c-99b2-cf4a84880394	0	\N
a4a7d50e-26dd-4b53-9948-5033323d4de7	8f9d8a5d-9fac-4975-91bb-b8ee5aa03130	bab68678-edd4-4485-8d72-ae998cdf02d0	1	\N
d7397f13-7a1b-4cc7-80f2-0e9ae26c09f4	8f9d8a5d-9fac-4975-91bb-b8ee5aa03130	df93db84-806c-4a93-99ed-c4ce6a35da56	0	\N
1d6056d8-9def-4953-99d9-05a5fb792294	8f9d8a5d-9fac-4975-91bb-b8ee5aa03130	f60c4cac-9215-452f-bcee-446724b4c5df	1	\N
40f35723-7a1f-4d19-8916-a1a8fa119376	8f9d8a5d-9fac-4975-91bb-b8ee5aa03130	3297f494-5c84-4607-a9c7-0cd373202fb7	1	\N
908b5bac-a50b-4412-90f1-8c8ac2135ef2	8f9d8a5d-9fac-4975-91bb-b8ee5aa03130	88a9cae7-4199-4255-84bb-918efee13770	0	\N
5c7a0929-4dca-49a0-b983-5676212d44a9	8f9d8a5d-9fac-4975-91bb-b8ee5aa03130	8114e989-f75e-43a0-9925-eb66ea58e908	2	\N
2c698fbd-6359-451c-84a7-60033425672a	8f9d8a5d-9fac-4975-91bb-b8ee5aa03130	02b972ab-70b6-43a4-8c52-97459d560128	0	\N
57aa3055-a940-4a9b-9210-f9438024755e	8f9d8a5d-9fac-4975-91bb-b8ee5aa03130	f762ddee-2a3b-4d4b-aa3d-d404e517fa69	0	\N
05e349b6-96bb-4577-a44f-c4adc777bdac	8f9d8a5d-9fac-4975-91bb-b8ee5aa03130	2d294931-dfb0-4ab3-a453-93c8b791d853	2	\N
75977704-bb63-47f2-9963-1d9cc7e852d9	8f9d8a5d-9fac-4975-91bb-b8ee5aa03130	d6c128a2-99da-4d80-937c-f684983e5171	0	\N
321c6722-484c-40c7-9252-96bdd4eadac4	8f9d8a5d-9fac-4975-91bb-b8ee5aa03130	e2a958ad-948b-4862-b15c-b2145ef2a440	0	\N
c62b15f1-874e-4ff4-8e8a-b5f35457bd5c	8f9d8a5d-9fac-4975-91bb-b8ee5aa03130	9bf793be-ca7b-4d9d-97d7-59de82bffc28	2	\N
ac931069-fc83-435f-9440-24e55032d912	8f9d8a5d-9fac-4975-91bb-b8ee5aa03130	e679ba89-1ef1-472f-b524-858c00d5ac2d	0	\N
f6456316-9466-44a6-b70c-c6b73eaaede9	8f9d8a5d-9fac-4975-91bb-b8ee5aa03130	e6a47da4-51ad-465c-bd95-4309370ee6b1	0	\N
adacd1f1-388a-40bb-8ffb-21c0b99964ec	8f9d8a5d-9fac-4975-91bb-b8ee5aa03130	14f29127-0c8b-4ec4-a7fa-f746ce8fa750	2	\N
5cfb7057-0ee8-43ff-8303-be99380c17b9	8f9d8a5d-9fac-4975-91bb-b8ee5aa03130	d0c602c2-6839-4e42-848e-959de7613821	0	\N
26049627-2893-45bc-900b-bb711b938826	8f9d8a5d-9fac-4975-91bb-b8ee5aa03130	2d58fa47-92c7-4635-a06f-48b23e7ca061	1	\N
7c26903b-6a61-48d0-b72d-bb863547c922	8f9d8a5d-9fac-4975-91bb-b8ee5aa03130	7aa1739e-1dd3-4ea5-8d82-ac738f77a9a3	2	\N
09582bca-b3fa-47f0-907c-dc466764e09e	8f9d8a5d-9fac-4975-91bb-b8ee5aa03130	dc1436c8-09d6-4c1d-b8b4-b71e501a6621	0	\N
b663176a-9544-4e33-ab28-c92272ad10cf	8f9d8a5d-9fac-4975-91bb-b8ee5aa03130	99de9373-47b9-4267-9741-de7b79d4f344	0	\N
d487ea48-6e60-4b30-b65a-7d21c0144212	8f9d8a5d-9fac-4975-91bb-b8ee5aa03130	7c34f4cf-f819-45a1-89e2-390cab528977	2	\N
17376d5b-d8f2-4019-af0e-8421a6ec9344	8f9d8a5d-9fac-4975-91bb-b8ee5aa03130	e1a3727c-1f71-4b07-80eb-31b202f61908	0	\N
4400b127-30bb-4f73-8b9e-67d33cf6a452	8f9d8a5d-9fac-4975-91bb-b8ee5aa03130	68fdc69d-6b79-45c5-ab30-30e1aefdafa4	0	\N
5b7b47ad-d0c0-4774-aac5-ade07465d537	8f9d8a5d-9fac-4975-91bb-b8ee5aa03130	98dc56aa-2b01-4639-aa73-ab9b865e272d	1	\N
551562d4-ccb7-46ae-a794-fba9f3363779	8f9d8a5d-9fac-4975-91bb-b8ee5aa03130	5faeffea-c30f-4bee-aca3-630b3ba24377	0	\N
4d058a0a-eb0d-4a9e-8135-bbae227c22e7	8f9d8a5d-9fac-4975-91bb-b8ee5aa03130	becc9d63-42d7-4fbf-b833-49a7c244520d	1	\N
bcc6150f-95b2-4228-a8d2-916eb207c45d	47f4b7fe-8642-4a38-a1d3-dab378b302d7	6e7aaf17-cee5-41ac-8637-0dca686d1f72	0	\N
d7fa49d9-f64f-44c2-83e3-64eface7015e	8f9d8a5d-9fac-4975-91bb-b8ee5aa03130	a5d9f334-465d-4f30-8e49-1de5a588dd7e	1	\N
487d88a9-2ab0-4440-8a92-27dd00fe2e72	47f4b7fe-8642-4a38-a1d3-dab378b302d7	b2d60abd-bf77-4f16-be34-3f5b62352885	0	\N
b0ea1b42-4391-4eed-bad3-fd0c636b4330	8f9d8a5d-9fac-4975-91bb-b8ee5aa03130	6f57f38f-f572-49af-9758-26d6e57a5746	1	\N
34b83a82-d66d-494e-ab7c-e4a410121f09	8f9d8a5d-9fac-4975-91bb-b8ee5aa03130	846e69cc-27e8-4308-9288-87c02b34d4a3	1	\N
6fb210b4-5a50-41b5-9380-73b3c1013e78	58855f44-a4f1-4a33-b446-63936dd87231	be7340fc-7ef9-47fb-9ee6-66e8bdf4528a	2	\N
9b003dd8-fd90-45ae-a48a-c5c9d33f6eca	47f4b7fe-8642-4a38-a1d3-dab378b302d7	c4b8d77b-797f-49b6-9ea8-7717d095997a	2	\N
4f3c39ea-1226-40cf-99b0-0fbe8cfeecfe	47f4b7fe-8642-4a38-a1d3-dab378b302d7	8079ef20-ca48-413d-abff-9bddd3ad7379	1	\N
329e80bb-1402-4ba8-a560-4d4cb9302505	58855f44-a4f1-4a33-b446-63936dd87231	7aa1739e-1dd3-4ea5-8d82-ac738f77a9a3	0	\N
b7ba73d8-6841-46b0-99c0-bb0363ef463e	47f4b7fe-8642-4a38-a1d3-dab378b302d7	d0cdaa45-472a-401d-ab1d-6c9628afc382	2	\N
b1ee0cca-edc2-4371-becd-0b9b4945d7d9	47f4b7fe-8642-4a38-a1d3-dab378b302d7	be7340fc-7ef9-47fb-9ee6-66e8bdf4528a	1	\N
82f49360-bda9-464f-bfbe-f4703c85b4dc	58855f44-a4f1-4a33-b446-63936dd87231	e0219d86-839f-447a-a310-4a7cc34af686	2	\N
acbb1e59-96ae-469c-b456-7f67207b3bd2	47f4b7fe-8642-4a38-a1d3-dab378b302d7	9a2d4ac0-c0ab-4e3a-a8d3-f0e184ef3d21	1	\N
ad4c56d2-e35c-49bc-8242-ffd803aadb45	47f4b7fe-8642-4a38-a1d3-dab378b302d7	326bd3ae-1b5f-47b1-853f-1516a7182669	2	\N
ff5ef05d-cb13-456d-8fec-7f093a760b2e	47f4b7fe-8642-4a38-a1d3-dab378b302d7	c1f28dd0-c438-49da-b093-f27a29a4fbe4	2	\N
853556af-0ac8-4b0d-82da-88bca5cf465f	47f4b7fe-8642-4a38-a1d3-dab378b302d7	0ba08c51-4ea3-4b96-b210-689f33edf0ff	2	\N
6119a488-d9ab-4a8e-9cd7-f0f3c2b59df5	47f4b7fe-8642-4a38-a1d3-dab378b302d7	e6a47da4-51ad-465c-bd95-4309370ee6b1	2	\N
85af89a0-d91e-4a9a-8ab6-fa7a0a9ba101	47f4b7fe-8642-4a38-a1d3-dab378b302d7	846e69cc-27e8-4308-9288-87c02b34d4a3	1	\N
8a7781e4-9531-49ff-b1fc-efff4c27bdba	58855f44-a4f1-4a33-b446-63936dd87231	b2d60abd-bf77-4f16-be34-3f5b62352885	2	\N
44ee7f25-8cd2-4293-9b87-db4f44e276a2	58855f44-a4f1-4a33-b446-63936dd87231	d0cdaa45-472a-401d-ab1d-6c9628afc382	2	\N
d32dd476-7608-4100-b8dc-3ef93381423c	58855f44-a4f1-4a33-b446-63936dd87231	e679ba89-1ef1-472f-b524-858c00d5ac2d	2	\N
ed1c33ad-33ec-4c87-bbb2-bc4e8501aacc	58855f44-a4f1-4a33-b446-63936dd87231	37c642e6-ec0f-4011-afd8-0d2bb77411a3	2	\N
7647708c-40e7-4877-a32a-00e7b023eb1d	58855f44-a4f1-4a33-b446-63936dd87231	99094616-1233-481d-be5f-d59fc0e8b3ee	0	\N
4d3e7ad6-1d82-48c2-9b92-8035e5cab6cd	58855f44-a4f1-4a33-b446-63936dd87231	6f57f38f-f572-49af-9758-26d6e57a5746	2	\N
441e17e4-d499-4d77-972e-ff661196eeca	58855f44-a4f1-4a33-b446-63936dd87231	5faeffea-c30f-4bee-aca3-630b3ba24377	2	\N
aead6eae-363c-44db-8028-ca6f48f6887f	dfaaf8c4-fa33-4200-9ee5-4daa39422c27	714354ab-5a24-448f-805b-05c846c13597	2	\N
68567067-9880-473f-b3dd-f2bc7935d310	dfaaf8c4-fa33-4200-9ee5-4daa39422c27	fed9b0f1-374f-443d-93b8-a68cfef0f8d0	2	\N
0b2453ce-0743-429c-a84e-edb9c54862f7	dfaaf8c4-fa33-4200-9ee5-4daa39422c27	0ac60ce0-9b6b-457e-ab20-1c4d3e6b8164	1	\N
3991734d-3625-4d52-a706-42bac3185223	dfaaf8c4-fa33-4200-9ee5-4daa39422c27	1459c1e8-4c40-42aa-bc76-719365d9b84f	1	\N
cec3ef03-1e78-4886-aa3b-f631a81c5237	dfaaf8c4-fa33-4200-9ee5-4daa39422c27	a5ebb569-491e-4f0c-9198-74711d119edc	1	\N
a8d80968-9b59-4df5-b525-ef5b6c3101d6	dfaaf8c4-fa33-4200-9ee5-4daa39422c27	3eccc514-0bed-40c4-ac6d-84741b75ee0f	1	\N
9d18a752-9d3d-4f1d-83d4-7c22094ca4e7	dfaaf8c4-fa33-4200-9ee5-4daa39422c27	4198b0fc-8c96-4f3f-a538-d34b39045cdf	1	\N
68a6e491-2ef3-490b-8872-b35aa5778143	dfaaf8c4-fa33-4200-9ee5-4daa39422c27	8ed3ffcc-3b59-47bf-9de4-36224220edc0	1	\N
c237a9a0-dc17-4287-a4ea-e13090173da2	dfaaf8c4-fa33-4200-9ee5-4daa39422c27	b5bacf10-72cd-4499-87e1-7acd901f0eba	1	\N
0fe33468-e140-4f22-9bbc-b7b2b13cec76	dfaaf8c4-fa33-4200-9ee5-4daa39422c27	6e7aaf17-cee5-41ac-8637-0dca686d1f72	1	\N
ce55290e-a285-4a3c-bddf-5be2c245d660	dfaaf8c4-fa33-4200-9ee5-4daa39422c27	4568ab20-a2ce-4cfa-91cd-9f4a1de997de	1	\N
1d01a256-a1c8-4dfb-b038-46e2ae043416	dfaaf8c4-fa33-4200-9ee5-4daa39422c27	b2d60abd-bf77-4f16-be34-3f5b62352885	2	\N
e83f9bc3-9a87-44bd-a47d-d590db7644c1	dfaaf8c4-fa33-4200-9ee5-4daa39422c27	21149ade-6555-4c27-a52f-3969e568354e	2	\N
17f77937-37dd-42c3-b818-8e01db50fc5b	dfaaf8c4-fa33-4200-9ee5-4daa39422c27	8079ef20-ca48-413d-abff-9bddd3ad7379	1	\N
90d83ba8-ae23-4eb1-ad20-b2a2dd0c3d10	dfaaf8c4-fa33-4200-9ee5-4daa39422c27	c4b8d77b-797f-49b6-9ea8-7717d095997a	2	\N
fc41c491-c103-4a07-8eb4-4005697fcbab	dfaaf8c4-fa33-4200-9ee5-4daa39422c27	d0cdaa45-472a-401d-ab1d-6c9628afc382	2	\N
79673a0a-a00a-4757-9051-8241d8b77713	dfaaf8c4-fa33-4200-9ee5-4daa39422c27	d131b6cc-e56f-42ef-a9ee-f12bb1059ac5	2	\N
f5abc816-4931-42c1-9cd3-41a5ed8ba042	dfaaf8c4-fa33-4200-9ee5-4daa39422c27	9a2d4ac0-c0ab-4e3a-a8d3-f0e184ef3d21	2	\N
eb8a0a95-4c60-4244-9a70-176de7259f9f	dfaaf8c4-fa33-4200-9ee5-4daa39422c27	4bddca33-9207-4b6c-a284-23e7fc1f8beb	1	\N
8fc18f7b-1dc9-43dd-ae9a-5f02add4e00d	dfaaf8c4-fa33-4200-9ee5-4daa39422c27	be7340fc-7ef9-47fb-9ee6-66e8bdf4528a	1	\N
\.


--
-- Data for Name: labs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.labs (id, lecturer_id, subject_id, title, description, created) FROM stdin;
26eb2041-66e6-485b-bdfb-20c9d9e623aa	1d666792-3cd9-493a-8091-0190f08acf37	6f1686d7-755c-48c6-8173-b7eb14c91a84	Лабораторная работа №1	Описание лабораторной работы	2025-06-23 19:36:06.592255
c2e066ce-5cc2-47ff-9f3f-5c95949fdd74	1d666792-3cd9-493a-8091-0190f08acf37	3502297e-b6f4-4a2c-8add-c56a724f7f91	Лабораторная работа №1	Описание лабораторной работы	2025-06-23 19:36:16.674291
4671b7aa-800a-4ee9-9229-a39d3e6230fb	1d666792-3cd9-493a-8091-0190f08acf37	b96268e0-fc9c-4130-9691-4335e7c7b77d	Лабораторная работа №1	Описание лабораторной работы	2025-06-23 19:36:29.775979
58855f44-a4f1-4a33-b446-63936dd87231	1d666792-3cd9-493a-8091-0190f08acf37	6f1686d7-755c-48c6-8173-b7eb14c91a84	Лабораторная работа №2	Описание для ЛБ	2025-06-23 19:41:59.713535
47f4b7fe-8642-4a38-a1d3-dab378b302d7	1d666792-3cd9-493a-8091-0190f08acf37	3502297e-b6f4-4a2c-8add-c56a724f7f91	Лабораторная работа №2	Описание для ЛБ	2025-06-23 19:42:06.872608
8f9d8a5d-9fac-4975-91bb-b8ee5aa03130	1d666792-3cd9-493a-8091-0190f08acf37	b96268e0-fc9c-4130-9691-4335e7c7b77d	Лабораторная работа №2	Описание для ЛБ	2025-06-23 19:42:13.74866
dfaaf8c4-fa33-4200-9ee5-4daa39422c27	1d666792-3cd9-493a-8091-0190f08acf37	6f1686d7-755c-48c6-8173-b7eb14c91a84	Лабораторная работа №3	Описание для ЛБ 3	2025-06-23 19:46:38.99206
\.


--
-- Data for Name: lecturer_groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.lecturer_groups (lecturer_id, group_id) FROM stdin;
1d666792-3cd9-493a-8091-0190f08acf37	fc561e17-c545-4174-bba0-289a189df90d
1d666792-3cd9-493a-8091-0190f08acf37	97d89647-7115-4e86-a86e-39887297835f
1d666792-3cd9-493a-8091-0190f08acf37	34906a73-5729-487b-9c10-77c254efb9d5
\.


--
-- Data for Name: lecturer_subjects; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.lecturer_subjects (lecturer_id, subject_id) FROM stdin;
1d666792-3cd9-493a-8091-0190f08acf37	6f1686d7-755c-48c6-8173-b7eb14c91a84
1d666792-3cd9-493a-8091-0190f08acf37	3502297e-b6f4-4a2c-8add-c56a724f7f91
1d666792-3cd9-493a-8091-0190f08acf37	b96268e0-fc9c-4130-9691-4335e7c7b77d
\.


--
-- Data for Name: lecturers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.lecturers (user_id, first_name, middle_name, last_name) FROM stdin;
1d666792-3cd9-493a-8091-0190f08acf37	Виктор	Александрович	Белов
76f8716b-8236-45be-9c7c-2a9c57441b91	Юрий	Васильевич	Смирнов
\.


--
-- Data for Name: students; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.students (user_id, first_name, middle_name, last_name, group_id) FROM stdin;
c19cafba-aeb4-4a0c-99b2-cf4a84880394	Вячеслав	Константинович	Сергеев	97d89647-7115-4e86-a86e-39887297835f
37c642e6-ec0f-4011-afd8-0d2bb77411a3	Тимофей	Андреевич	Данилов	97d89647-7115-4e86-a86e-39887297835f
9bf793be-ca7b-4d9d-97d7-59de82bffc28	Рустам	Михайлович	Тихонов	97d89647-7115-4e86-a86e-39887297835f
02b972ab-70b6-43a4-8c52-97459d560128	Вячеслав	Витальевич	Тарасов	97d89647-7115-4e86-a86e-39887297835f
326bd3ae-1b5f-47b1-853f-1516a7182669	Иван	Дмитриевич	Егоров	97d89647-7115-4e86-a86e-39887297835f
f60c4cac-9215-452f-bcee-446724b4c5df	Роман	Львович	Иванов	97d89647-7115-4e86-a86e-39887297835f
3297f494-5c84-4607-a9c7-0cd373202fb7	Вячеслав	Андреевич	Сергеев	97d89647-7115-4e86-a86e-39887297835f
e0219d86-839f-447a-a310-4a7cc34af686	Семен	Викторович	Александров	97d89647-7115-4e86-a86e-39887297835f
88a9cae7-4199-4255-84bb-918efee13770	Игорь	Григорьевич	Смирнов	97d89647-7115-4e86-a86e-39887297835f
bab68678-edd4-4485-8d72-ae998cdf02d0	Виктор	Александрович	Зайцев	97d89647-7115-4e86-a86e-39887297835f
c976199c-dc57-4144-9b8a-811380ecde1b	Дмитрий	Дмитриевич	Сергеев	97d89647-7115-4e86-a86e-39887297835f
7130dde9-c15e-462d-9384-b560e1b10693	Алексей	Егорович	Петров	97d89647-7115-4e86-a86e-39887297835f
8114e989-f75e-43a0-9925-eb66ea58e908	Анатолий	Андреевич	Крылов	97d89647-7115-4e86-a86e-39887297835f
2d294931-dfb0-4ab3-a453-93c8b791d853	Анатолий	Егорович	Михайлов	97d89647-7115-4e86-a86e-39887297835f
99094616-1233-481d-be5f-d59fc0e8b3ee	Фёдор	Львович	Морозов	97d89647-7115-4e86-a86e-39887297835f
f762ddee-2a3b-4d4b-aa3d-d404e517fa69	Игорь	Семёнович	Тарасов	97d89647-7115-4e86-a86e-39887297835f
7aa1739e-1dd3-4ea5-8d82-ac738f77a9a3	Анатолий	Сергеевич	Шестаков	97d89647-7115-4e86-a86e-39887297835f
c1f28dd0-c438-49da-b093-f27a29a4fbe4	Фёдор	Никитич	Романов	97d89647-7115-4e86-a86e-39887297835f
56fbc3fc-0d8b-4e53-bc71-f16dff24d03f	Егор	Сергеевич	Новиков	97d89647-7115-4e86-a86e-39887297835f
14f29127-0c8b-4ec4-a7fa-f746ce8fa750	Рустам	Семёнович	Шестаков	97d89647-7115-4e86-a86e-39887297835f
98dc56aa-2b01-4639-aa73-ab9b865e272d	Дмитрий	Семёнович	Морозов	34906a73-5729-487b-9c10-77c254efb9d5
df93db84-806c-4a93-99ed-c4ce6a35da56	Николай	Тимофеевич	Александров	34906a73-5729-487b-9c10-77c254efb9d5
6f57f38f-f572-49af-9758-26d6e57a5746	Максим	Степанович	Сергеев	34906a73-5729-487b-9c10-77c254efb9d5
a5d9f334-465d-4f30-8e49-1de5a588dd7e	Андрей	Николаевич	Сергеев	34906a73-5729-487b-9c10-77c254efb9d5
99de9373-47b9-4267-9741-de7b79d4f344	Алексей	Иванович	Тарасов	34906a73-5729-487b-9c10-77c254efb9d5
7c8a5806-8bf0-4872-a69b-61dcc97a46a6	Аркадий	Павлович	Александров	34906a73-5729-487b-9c10-77c254efb9d5
68fdc69d-6b79-45c5-ab30-30e1aefdafa4	Юрий	Васильевич	Тихонов	34906a73-5729-487b-9c10-77c254efb9d5
2d58fa47-92c7-4635-a06f-48b23e7ca061	Игорь	Васильевич	Соколов	34906a73-5729-487b-9c10-77c254efb9d5
dc1436c8-09d6-4c1d-b8b4-b71e501a6621	Лев	Викторович	Тарасов	34906a73-5729-487b-9c10-77c254efb9d5
0ba08c51-4ea3-4b96-b210-689f33edf0ff	Сергей	Романович	Александров	34906a73-5729-487b-9c10-77c254efb9d5
e679ba89-1ef1-472f-b524-858c00d5ac2d	Игорь	Никитич	Крылов	34906a73-5729-487b-9c10-77c254efb9d5
d0c602c2-6839-4e42-848e-959de7613821	Роман	Вячеславович	Макаров	34906a73-5729-487b-9c10-77c254efb9d5
5faeffea-c30f-4bee-aca3-630b3ba24377	Дмитрий	Вячеславович	Шестаков	34906a73-5729-487b-9c10-77c254efb9d5
becc9d63-42d7-4fbf-b833-49a7c244520d	Роман	Алексеевич	Петров	34906a73-5729-487b-9c10-77c254efb9d5
7c34f4cf-f819-45a1-89e2-390cab528977	Юрий	Витальевич	Михайлов	34906a73-5729-487b-9c10-77c254efb9d5
e1a3727c-1f71-4b07-80eb-31b202f61908	Рустам	Юрьевич	Михайлов	34906a73-5729-487b-9c10-77c254efb9d5
d6c128a2-99da-4d80-937c-f684983e5171	Лев	Михайлович	Иванов	34906a73-5729-487b-9c10-77c254efb9d5
846e69cc-27e8-4308-9288-87c02b34d4a3	Никита	Анатольевич	Сидоров	34906a73-5729-487b-9c10-77c254efb9d5
e2a958ad-948b-4862-b15c-b2145ef2a440	Григорий	Григорьевич	Козлов	34906a73-5729-487b-9c10-77c254efb9d5
e6a47da4-51ad-465c-bd95-4309370ee6b1	Степан	Федорович	Макаров	34906a73-5729-487b-9c10-77c254efb9d5
b5bacf10-72cd-4499-87e1-7acd901f0eba	Аркадий	Григорьевич	Тарасов	fc561e17-c545-4174-bba0-289a189df90d
8079ef20-ca48-413d-abff-9bddd3ad7379	Николай	Витальевич	Григорьев	fc561e17-c545-4174-bba0-289a189df90d
1459c1e8-4c40-42aa-bc76-719365d9b84f	Егор	Юрьевич	Попов	fc561e17-c545-4174-bba0-289a189df90d
8ed3ffcc-3b59-47bf-9de4-36224220edc0	Дмитрий	Викторович	Соколов	fc561e17-c545-4174-bba0-289a189df90d
be7340fc-7ef9-47fb-9ee6-66e8bdf4528a	Григорий	Егорович	Смирнов	fc561e17-c545-4174-bba0-289a189df90d
714354ab-5a24-448f-805b-05c846c13597	Степан	Андреевич	Егоров	fc561e17-c545-4174-bba0-289a189df90d
0ac60ce0-9b6b-457e-ab20-1c4d3e6b8164	Роман	Олегович	Попов	fc561e17-c545-4174-bba0-289a189df90d
3eccc514-0bed-40c4-ac6d-84741b75ee0f	Максим	Степанович	Козлов	fc561e17-c545-4174-bba0-289a189df90d
fed9b0f1-374f-443d-93b8-a68cfef0f8d0	Андрей	Федорович	Зайцев	fc561e17-c545-4174-bba0-289a189df90d
4198b0fc-8c96-4f3f-a538-d34b39045cdf	Анатолий	Витальевич	Соколов	fc561e17-c545-4174-bba0-289a189df90d
a5ebb569-491e-4f0c-9198-74711d119edc	Максим	Вячеславович	Сидоров	fc561e17-c545-4174-bba0-289a189df90d
21149ade-6555-4c27-a52f-3969e568354e	Никита	Витальевич	Волков	fc561e17-c545-4174-bba0-289a189df90d
4568ab20-a2ce-4cfa-91cd-9f4a1de997de	Михаил	Константинович	Васильев	fc561e17-c545-4174-bba0-289a189df90d
6e7aaf17-cee5-41ac-8637-0dca686d1f72	Виктор	Викторович	Александров	fc561e17-c545-4174-bba0-289a189df90d
d131b6cc-e56f-42ef-a9ee-f12bb1059ac5	Лев	Львович	Зайцев	fc561e17-c545-4174-bba0-289a189df90d
9a2d4ac0-c0ab-4e3a-a8d3-f0e184ef3d21	Владимир	Романович	Тихонов	fc561e17-c545-4174-bba0-289a189df90d
4bddca33-9207-4b6c-a284-23e7fc1f8beb	Иван	Андреевич	Козлов	fc561e17-c545-4174-bba0-289a189df90d
c4b8d77b-797f-49b6-9ea8-7717d095997a	Сергей	Анатольевич	Григорьев	fc561e17-c545-4174-bba0-289a189df90d
b2d60abd-bf77-4f16-be34-3f5b62352885	Егор	Викторович	Васильев	fc561e17-c545-4174-bba0-289a189df90d
d0cdaa45-472a-401d-ab1d-6c9628afc382	Алексей	Львович	Егоров	fc561e17-c545-4174-bba0-289a189df90d
\.


--
-- Data for Name: subjects; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subjects (id, name) FROM stdin;
b96268e0-fc9c-4130-9691-4335e7c7b77d	Моделирование
6f1686d7-755c-48c6-8173-b7eb14c91a84	Аппаратная реализация алгоритмов
65bdbdc2-6c35-4235-a2a7-de5f1387f975	Тестирование программного обеспечения
3502297e-b6f4-4a2c-8add-c56a724f7f91	Модели и методы искусственного интеллекта
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
-- Data for Name: tokens; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tokens (id, user_id, refresh_token, ip_address, user_agent, unique_id, created_at, expires_at, is_revoked) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, email, password, role) FROM stdin;
fd9005b3-99d8-4545-a983-f12190dab706	testadmin@mail.ru	$2b$10$oGmjm8JWRAR.FnZabt1N5.dxfrbej/ZASfugm9UF/Zwsnu4PKZzFK	admin
c19cafba-aeb4-4a0c-99b2-cf4a84880394	test1@mail.ru	$2b$10$zN7BDykaLCa7rLIATeLi.O.b/m7d/L1ZoOztgfpKJXBk/ljCMTnX.	student
37c642e6-ec0f-4011-afd8-0d2bb77411a3	test2@mail.ru	$2b$10$AXt8TEX/Czen5oRYPpo9WOHsGN1eDCHc3dTOizpphxViL1a4KbcZC	student
9bf793be-ca7b-4d9d-97d7-59de82bffc28	test3@mail.ru	$2b$10$wtJdz0CFbMe965G4G7TEG.FvMVwMnjFGkvFg.P6ztWGabaMOOjKLC	student
02b972ab-70b6-43a4-8c52-97459d560128	test4@mail.ru	$2b$10$dDlG9OhGaqRi/./nf0vMauF.k7EGHzip3cDyT/qIseHmTQNpltMjy	student
326bd3ae-1b5f-47b1-853f-1516a7182669	test5@mail.ru	$2b$10$K9wmU0eqRPMkUXCs5igUZO0FAvmrftM85...enKJB15FeqKm73ZH2	student
f60c4cac-9215-452f-bcee-446724b4c5df	test6@mail.ru	$2b$10$bi5tLYFurRFzlaDjD1VjIOJX0fs6AYAMm2OzLk49iJHGIefmwONBa	student
3297f494-5c84-4607-a9c7-0cd373202fb7	test7@mail.ru	$2b$10$7TfwVFUGZsKTp1ctIpsp0ez3WeQVqkaPz1hPBrzn9Iyxxc4aUknge	student
e0219d86-839f-447a-a310-4a7cc34af686	test8@mail.ru	$2b$10$redo8Khp1yR/WDyv6Orf9uQWHxLe44PyOCcXUkK95dSnYhAKuefI6	student
88a9cae7-4199-4255-84bb-918efee13770	test9@mail.ru	$2b$10$6GqYaWcGx7CO.BoSIuB8uuM25lG2l1.FvNSE6NlAb1xaM.KpyJ3bC	student
bab68678-edd4-4485-8d72-ae998cdf02d0	test10@mail.ru	$2b$10$ujSUxdvhQIwWXQfSCb6EP.nQHWbPbLfJ71P4UjNhugJ37uMANu5iG	student
c976199c-dc57-4144-9b8a-811380ecde1b	test11@mail.ru	$2b$10$UIseZ.Jmg71U2w2q0pikRejlTRyaVsyHP51f8PB4pcr84mUT7wCz6	student
7130dde9-c15e-462d-9384-b560e1b10693	test12@mail.ru	$2b$10$BvOcGtJBQQVa.0WNXoHojubYF7iNCWr1vZTuDwqvr0algbA5IfIJ.	student
8114e989-f75e-43a0-9925-eb66ea58e908	test13@mail.ru	$2b$10$rJlgsyPdPkxmgRysXtyRyu2rsQJUea59cVCgL5aaackM54GFxcuCa	student
2d294931-dfb0-4ab3-a453-93c8b791d853	test14@mail.ru	$2b$10$RN9xp/q2cihcpuScNyvL/emtfa6gV0P95UfF1r10TqXnH0i1AOZrO	student
99094616-1233-481d-be5f-d59fc0e8b3ee	test15@mail.ru	$2b$10$waSmj8DbzZwV6xcivLSRD.Q6nMcICDcOGqcMmKUBlf4BiMUQEBELy	student
f762ddee-2a3b-4d4b-aa3d-d404e517fa69	test16@mail.ru	$2b$10$k4IzQ2toBzhHGZtUAPiVH.bMf4r1hRPrnsWCupmoy/fab/5w02HIq	student
7aa1739e-1dd3-4ea5-8d82-ac738f77a9a3	test17@mail.ru	$2b$10$Re9BLxloSWSYx6DNfjw.ueURjHsrEP8iabUI0jzHxAnbsBHV/vW6q	student
c1f28dd0-c438-49da-b093-f27a29a4fbe4	test18@mail.ru	$2b$10$0SvtG38PGmH6YKqd1jMT1uh8meARRYvgkuZPpvP7L5O7ZMLOd4ocu	student
56fbc3fc-0d8b-4e53-bc71-f16dff24d03f	test19@mail.ru	$2b$10$YcMrNIb/Th9C9hM2iQXr8eW/FL8rolcggBjv1ixE6lSKuRr3r4.5W	student
14f29127-0c8b-4ec4-a7fa-f746ce8fa750	test20@mail.ru	$2b$10$Ffb84X1tIMKiPYrYJhGFfe33hmRzk9hZkLq7slTG5lLkkuQh3MP6u	student
98dc56aa-2b01-4639-aa73-ab9b865e272d	test21@mail.ru	$2b$10$7/VI3bLtBMVX1Rp0EeetCueXxzgfD44f0ifI84DvR2Y4faH1keBc6	student
df93db84-806c-4a93-99ed-c4ce6a35da56	test22@mail.ru	$2b$10$ELAVuxl9ai8gpEgx9Fgu9.Iq4fmzLNhbohmUwZIEOObWU4XF9qWVu	student
6f57f38f-f572-49af-9758-26d6e57a5746	test23@mail.ru	$2b$10$OcZWMmRe6KmGh2DZ5e9tm.0oZ8NeYFDAU/HHc7X69Ak4oZqt5s3VS	student
a5d9f334-465d-4f30-8e49-1de5a588dd7e	test24@mail.ru	$2b$10$0qzX.8iW9rhb47JK0YSB8u05vmUlJah9wzUz4D6Q5sgxnAG3Qr9n.	student
99de9373-47b9-4267-9741-de7b79d4f344	test25@mail.ru	$2b$10$8hH97sq.bseZ4n0NaZMiPeFWnZTkQlTe0FP2ZF4d.RRiQLzWd8g7G	student
7c8a5806-8bf0-4872-a69b-61dcc97a46a6	test26@mail.ru	$2b$10$TN9TVxVu6vKjWeaJ0hQG7.2Ll5tBVJSELvAIQ9tKXk55lFp4aTpmu	student
68fdc69d-6b79-45c5-ab30-30e1aefdafa4	test27@mail.ru	$2b$10$JHoHy2zi6O0WQ/4i4Hq1ueq/7wnIdrhDaQXhxvBhp/3QzWVfHaAnS	student
2d58fa47-92c7-4635-a06f-48b23e7ca061	test28@mail.ru	$2b$10$3WlSJYa6cD5jbXF3c2.mNuP8dO6jmXTjxgplvIOYkbYHDDQ.kHWTm	student
dc1436c8-09d6-4c1d-b8b4-b71e501a6621	test29@mail.ru	$2b$10$8hlNvWov0vcEZjwevcZEKeu8SCt.2pOsefGD8HYLJHqiLX4fcbg.y	student
0ba08c51-4ea3-4b96-b210-689f33edf0ff	test30@mail.ru	$2b$10$lwBLZ13HeOua3JMz.rxU5.26bp6SV1hk8UPGeVD/LYZ9rBgwpFG9C	student
e679ba89-1ef1-472f-b524-858c00d5ac2d	test31@mail.ru	$2b$10$hJyQ24mI/87z.vBeWpkUu.9u7MpuWCR.r0ZltJW.EFymmSpqZrQeS	student
d0c602c2-6839-4e42-848e-959de7613821	test32@mail.ru	$2b$10$OHBMnNZwTZutFAyt..pGLecKVUeWLYiy7NgZH4sH/QX6yWpr7UHAG	student
5faeffea-c30f-4bee-aca3-630b3ba24377	test33@mail.ru	$2b$10$4dJv8MIGA.9nAfvoF29Wse78nqbRJCVIv49iJoTih2qnyCGnqIhOu	student
becc9d63-42d7-4fbf-b833-49a7c244520d	test34@mail.ru	$2b$10$ZSzJhvjiPQw0K/U2.4gT/uuJUdOdxy6psiLElN2bY5bTyq/dmtQ8O	student
7c34f4cf-f819-45a1-89e2-390cab528977	test35@mail.ru	$2b$10$tZ2RrSQ7nZb/5uwcoMUrKOMstlQp8m.ZRk4W3fbxcczjiTsJvW8uC	student
e1a3727c-1f71-4b07-80eb-31b202f61908	test36@mail.ru	$2b$10$tXW25rpU3OlIcgWKmrwuYOzmou7Dh0QOjkwcfPhhCYSW6r5QvmibS	student
d6c128a2-99da-4d80-937c-f684983e5171	test37@mail.ru	$2b$10$2VsX1.zUod9hNUFhumBOD.jhTKajFXPfAuzrtrtY/2BSwtcV53pLy	student
846e69cc-27e8-4308-9288-87c02b34d4a3	test38@mail.ru	$2b$10$wLCj54va6RxHdeuloNe6uO1y0B2ZDKXpyJvQ8atI51LNvHKd2Lvqm	student
e2a958ad-948b-4862-b15c-b2145ef2a440	test39@mail.ru	$2b$10$BOE5D88MwHH9F/1QT3UYj.YbnAaRyqbhZWCR3OrWOCru3pD0vTevq	student
e6a47da4-51ad-465c-bd95-4309370ee6b1	test40@mail.ru	$2b$10$Na7g4Gz88mc9YbQpYeA/K.47weq.WefVhx/Xgx6/FaQJCAxsfULgG	student
b5bacf10-72cd-4499-87e1-7acd901f0eba	test41@mail.ru	$2b$10$Nu/nT1HXYsEu16ENW6NKkeBkWSS27lEusplXBwf5LQ.AKxPW11pQ.	student
8079ef20-ca48-413d-abff-9bddd3ad7379	test42@mail.ru	$2b$10$x19PNvUbnlV2DkcOyUdF0uPy1rkosZeDxioEjt/NJaqVgmZ7FDWfC	student
1459c1e8-4c40-42aa-bc76-719365d9b84f	test43@mail.ru	$2b$10$3Xx4dANibYef4ptXJoG2huHFMvdn2oP9ZLYjvU9VoHX1dxfuGwX6K	student
8ed3ffcc-3b59-47bf-9de4-36224220edc0	test44@mail.ru	$2b$10$h/2b2BWySpWwF8vpg/qpg.cX1T7fAIfFGkJ6FaA26P.Rboh91xXZK	student
be7340fc-7ef9-47fb-9ee6-66e8bdf4528a	test45@mail.ru	$2b$10$4kFO.BDQbADfASkVat8oF.dv5N3FP08y7ldwPcPhYQLvYfQc27Mw.	student
714354ab-5a24-448f-805b-05c846c13597	test46@mail.ru	$2b$10$a2Gfg/SMVYRFwkn2yKzVde7m72B/iHAVLIwaOWzGCwgRYBT.4fAhS	student
0ac60ce0-9b6b-457e-ab20-1c4d3e6b8164	test47@mail.ru	$2b$10$jW0lU/fg3siAS/fFP.0V/udT0iRkRMnb0rhzN6ZiJipviVkwtu6Aq	student
3eccc514-0bed-40c4-ac6d-84741b75ee0f	test48@mail.ru	$2b$10$5vvR8UrL7uRJ.Tf.WZy7Ju/e6Iv01JVZo1Iv8RintvKqyV6S1iKfm	student
fed9b0f1-374f-443d-93b8-a68cfef0f8d0	test49@mail.ru	$2b$10$tRsBNKdSWTg1kubhFiDcxuaep4xxQoeyfiEtT3xek31y4wpuKvhnm	student
4198b0fc-8c96-4f3f-a538-d34b39045cdf	test50@mail.ru	$2b$10$UDiW5ffdVpdhMrH3E8xSpe08Maidf9Sgt87afIIuSda0tg4QKy3zK	student
a5ebb569-491e-4f0c-9198-74711d119edc	test51@mail.ru	$2b$10$cIa4iMIrTQHh31yUK1tml.S01oTqKnbnXeemyfavbyhYZ8YQ55CP6	student
21149ade-6555-4c27-a52f-3969e568354e	test52@mail.ru	$2b$10$5gwb8olNLkVp/PsVYVc7Je24ejLShLo3M.64p4QTk6QYTN8JKQ636	student
4568ab20-a2ce-4cfa-91cd-9f4a1de997de	test53@mail.ru	$2b$10$b5WQ/Yu0dPL85sdHItrEZuAOQBuesr8pMuORUXRpULkAS.HV196wa	student
6e7aaf17-cee5-41ac-8637-0dca686d1f72	test54@mail.ru	$2b$10$haQWg0eI8c5EhwbTjkQ0oOnuR3zXlMwTg0zjqu4i28uvxgLC/engm	student
d131b6cc-e56f-42ef-a9ee-f12bb1059ac5	test55@mail.ru	$2b$10$1AlsfRk3YdTX9USYsQ4yx.6MktHfutQjmyf4xZeQLJhhi4Rknwehq	student
9a2d4ac0-c0ab-4e3a-a8d3-f0e184ef3d21	test56@mail.ru	$2b$10$EzP5lMP3mjp4mPvYYszon./We2IctFG.6zqGUXVOvB3ceHnLW2bwu	student
4bddca33-9207-4b6c-a284-23e7fc1f8beb	test57@mail.ru	$2b$10$J5iZKR8KjmYykvE.4M/Erer40BdWbTKE4SaYMP/KUn2vwh2/rBfEm	student
c4b8d77b-797f-49b6-9ea8-7717d095997a	test58@mail.ru	$2b$10$LAIBfMCxLMqs3Y27hYHvqerrrYGy6hE2EYdVqD506dAxEqcIfHF.q	student
b2d60abd-bf77-4f16-be34-3f5b62352885	test59@mail.ru	$2b$10$j12wIAjfpCoFMbYuH4t4GeRynxvWpcej/rEHL8.Qsbco6sPsb64V6	student
d0cdaa45-472a-401d-ab1d-6c9628afc382	test60@mail.ru	$2b$10$YCfjEi.tuD8qJy8pk5uDzunWrVYMUWuLcOTxUj9SD7lORydFMbt9G	student
1d666792-3cd9-493a-8091-0190f08acf37	testlecturer1@mail.ru	$2b$10$C3so3tMgZQN/wGmNQBNZw.ThQzryRpyi8Cnk0oqDZs1HdSDoVCAMK	lecturer
76f8716b-8236-45be-9c7c-2a9c57441b91	testlecturer2@mail.ru	$2b$10$Nn9cgDrGebEFAiWfWfedO.vt2LiAFu/hjWdN1YIYkeBCs1UuS989W	lecturer
b475d48e-a2b0-41bb-8bb7-21d0bd93f42a	testadmin2@mail.ru	$2b$10$Q4PoRgHzJy7kfpRCaEmcgeAjSqRvuMJeeHtF8b7.f/BOA3U1OieLa	admin
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
-- Name: tokens tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tokens
    ADD CONSTRAINT tokens_pkey PRIMARY KEY (id);


--
-- Name: tokens tokens_user_id_unique_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tokens
    ADD CONSTRAINT tokens_user_id_unique_id_key UNIQUE (user_id, unique_id);


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
-- Name: tokens tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tokens
    ADD CONSTRAINT tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;


--
-- PostgreSQL database dump complete
--

