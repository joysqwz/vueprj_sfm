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
-- Name: groups; Type: TABLE; Schema: public; Owner: mega-postgrs
--

CREATE TABLE public.groups (
    id uuid NOT NULL,
    name character varying(255) NOT NULL
);


ALTER TABLE public.groups OWNER TO mega-postgrs;

--
-- Name: lab_files; Type: TABLE; Schema: public; Owner: mega-postgrs
--

CREATE TABLE public.lab_files (
    id uuid NOT NULL,
    lab_id uuid NOT NULL,
    file_name character varying(255) NOT NULL,
    file_path character varying(255) NOT NULL
);


ALTER TABLE public.lab_files OWNER TO mega-postgrs;

--
-- Name: lab_groups; Type: TABLE; Schema: public; Owner: mega-postgrs
--

CREATE TABLE public.lab_groups (
    lab_id uuid NOT NULL,
    group_id uuid NOT NULL
);


ALTER TABLE public.lab_groups OWNER TO mega-postgrs;

--
-- Name: lab_submission_files; Type: TABLE; Schema: public; Owner: mega-postgrs
--

CREATE TABLE public.lab_submission_files (
    id uuid NOT NULL,
    lab_submission_id uuid NOT NULL,
    file_name character varying(255) NOT NULL,
    file_path character varying(255) NOT NULL
);


ALTER TABLE public.lab_submission_files OWNER TO mega-postgrs;

--
-- Name: lab_submissions; Type: TABLE; Schema: public; Owner: mega-postgrs
--

CREATE TABLE public.lab_submissions (
    id uuid NOT NULL,
    lab_id uuid NOT NULL,
    student_id uuid NOT NULL,
    grade integer,
    submitted_at timestamp without time zone
);


ALTER TABLE public.lab_submissions OWNER TO mega-postgrs;

--
-- Name: labs; Type: TABLE; Schema: public; Owner: mega-postgrs
--

CREATE TABLE public.labs (
    id uuid NOT NULL,
    lecturer_id uuid NOT NULL,
    subject_id uuid NOT NULL,
    title character varying(255) NOT NULL,
    description text,
    created timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.labs OWNER TO mega-postgrs;

--
-- Name: lecturer_groups; Type: TABLE; Schema: public; Owner: mega-postgrs
--

CREATE TABLE public.lecturer_groups (
    lecturer_id uuid NOT NULL,
    group_id uuid NOT NULL
);


ALTER TABLE public.lecturer_groups OWNER TO mega-postgrs;

--
-- Name: lecturer_subjects; Type: TABLE; Schema: public; Owner: mega-postgrs
--

CREATE TABLE public.lecturer_subjects (
    lecturer_id uuid NOT NULL,
    subject_id uuid NOT NULL
);


ALTER TABLE public.lecturer_subjects OWNER TO mega-postgrs;

--
-- Name: lecturers; Type: TABLE; Schema: public; Owner: mega-postgrs
--

CREATE TABLE public.lecturers (
    user_id uuid NOT NULL,
    first_name character varying(255) NOT NULL,
    middle_name character varying(255),
    last_name character varying(255) NOT NULL
);


ALTER TABLE public.lecturers OWNER TO mega-postgrs;

--
-- Name: students; Type: TABLE; Schema: public; Owner: mega-postgrs
--

CREATE TABLE public.students (
    user_id uuid NOT NULL,
    first_name character varying(255) NOT NULL,
    middle_name character varying(255),
    last_name character varying(255) NOT NULL,
    group_id uuid
);


ALTER TABLE public.students OWNER TO mega-postgrs;

--
-- Name: subjects; Type: TABLE; Schema: public; Owner: mega-postgrs
--

CREATE TABLE public.subjects (
    id uuid NOT NULL,
    name character varying(255) NOT NULL
);


ALTER TABLE public.subjects OWNER TO mega-postgrs;

--
-- Name: temp_tokens; Type: TABLE; Schema: public; Owner: mega-postgrs
--

CREATE TABLE public.temp_tokens (
    user_id uuid NOT NULL,
    temp_token text NOT NULL,
    code character varying(6) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    expires_at timestamp without time zone NOT NULL
);


ALTER TABLE public.temp_tokens OWNER TO mega-postgrs;

--
-- Name: token; Type: TABLE; Schema: public; Owner: mega-postgrs
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


ALTER TABLE public.token OWNER TO mega-postgrs;

--
-- Name: users; Type: TABLE; Schema: public; Owner: mega-postgrs
--

CREATE TABLE public.users (
    id uuid NOT NULL,
    email character varying(255) NOT NULL,
    password character varying(255) NOT NULL,
    role character varying(20) NOT NULL,
    CONSTRAINT users_role_check CHECK (((role)::text = ANY ((ARRAY['admin'::character varying, 'lecturer'::character varying, 'student'::character varying])::text[])))
);


ALTER TABLE public.users OWNER TO mega-postgrs;

--
-- Data for Name: groups; Type: TABLE DATA; Schema: public; Owner: mega-postgrs
--

COPY public.groups (id, name) FROM stdin;
b99c24f9-8141-400c-8c38-cdb37d3daf5c	ПО1-21
b28abc04-b83c-4522-97b3-b2c474c0ae08	ПО2-21
bb8bd1de-f50e-49b0-b984-c2e7066e0436	АС-21
\.


--
-- Data for Name: lab_files; Type: TABLE DATA; Schema: public; Owner: mega-postgrs
--

COPY public.lab_files (id, lab_id, file_name, file_path) FROM stdin;
\.


--
-- Data for Name: lab_groups; Type: TABLE DATA; Schema: public; Owner: mega-postgrs
--

COPY public.lab_groups (lab_id, group_id) FROM stdin;
509ade72-1836-461d-9435-67caf821afb0	bb8bd1de-f50e-49b0-b984-c2e7066e0436
00005960-5adf-4834-b188-3aa30121c5dc	b99c24f9-8141-400c-8c38-cdb37d3daf5c
41da3104-ea6d-4906-a961-9d31e34fd2d1	b28abc04-b83c-4522-97b3-b2c474c0ae08
eabcf0da-f8e5-443a-8923-929365b14727	b28abc04-b83c-4522-97b3-b2c474c0ae08
eabcf0da-f8e5-443a-8923-929365b14727	bb8bd1de-f50e-49b0-b984-c2e7066e0436
eabcf0da-f8e5-443a-8923-929365b14727	b99c24f9-8141-400c-8c38-cdb37d3daf5c
371e992d-42d2-4393-b08e-d36e3ff49db5	b28abc04-b83c-4522-97b3-b2c474c0ae08
371e992d-42d2-4393-b08e-d36e3ff49db5	bb8bd1de-f50e-49b0-b984-c2e7066e0436
371e992d-42d2-4393-b08e-d36e3ff49db5	b99c24f9-8141-400c-8c38-cdb37d3daf5c
8f347975-0f73-4414-b7a8-b555158b5333	b99c24f9-8141-400c-8c38-cdb37d3daf5c
\.


--
-- Data for Name: lab_submission_files; Type: TABLE DATA; Schema: public; Owner: mega-postgrs
--

COPY public.lab_submission_files (id, lab_submission_id, file_name, file_path) FROM stdin;
\.


--
-- Data for Name: lab_submissions; Type: TABLE DATA; Schema: public; Owner: mega-postgrs
--

COPY public.lab_submissions (id, lab_id, student_id, grade, submitted_at) FROM stdin;
aad7826d-8128-4dbf-aaa1-f2494389767f	509ade72-1836-461d-9435-67caf821afb0	aed87aee-d487-4558-8095-a88cc4bf9ff6	\N	\N
eddf1bf6-63cb-4b74-8035-c9f5e69ee9a2	509ade72-1836-461d-9435-67caf821afb0	26be8619-fd70-4e13-94b7-735568ea82d7	\N	\N
a385d84d-19ef-4b08-bdd4-66ea3a136c5e	509ade72-1836-461d-9435-67caf821afb0	88be355b-b152-4071-9f9c-741c1d7d83f8	\N	\N
b6cb1878-5c50-4fbe-b697-1aede560d12e	509ade72-1836-461d-9435-67caf821afb0	53f6e22a-822e-4819-9506-02ed80ca66e6	\N	\N
f1a4b2b3-fcac-4db3-96fe-bc3d7116fac4	509ade72-1836-461d-9435-67caf821afb0	a7a5fe0d-962f-46a6-9361-0db18ec11eca	\N	\N
7200e31f-6424-4cad-a412-ce81eab0e363	509ade72-1836-461d-9435-67caf821afb0	b7909343-53d3-4c2f-bf3a-f4e2ca47d805	\N	\N
a74e04d7-bb16-47c1-ae46-c1c6130e0815	509ade72-1836-461d-9435-67caf821afb0	cc8a241c-b0a3-4a7b-a632-6073a46374c7	\N	\N
99b56a32-45b0-424d-bd05-71a34a76b064	509ade72-1836-461d-9435-67caf821afb0	3e12dc69-ea5d-4e52-bc87-6b52f5aefef9	\N	\N
95a24252-cd0d-4ffe-a8b1-4b17f934596b	509ade72-1836-461d-9435-67caf821afb0	49217046-631c-4098-a232-0c225ebcaf6e	\N	\N
71403703-9d40-4a60-bed7-3b46f87e75a8	509ade72-1836-461d-9435-67caf821afb0	5379ebbc-9376-4aa8-80d0-949ec2fd5ac5	\N	\N
7a2418dc-b847-44e2-8ea0-ae04b44127d9	509ade72-1836-461d-9435-67caf821afb0	0b1e18c5-6194-4eb3-a25a-29ef79cb06f3	\N	\N
03ff04ac-09f3-4882-ab1a-50dd9202de63	509ade72-1836-461d-9435-67caf821afb0	9abb6cdd-40e4-45b5-a00a-0d78239e29f1	\N	\N
a8d8b0f6-b9ec-4649-bc3d-9780d0c94133	509ade72-1836-461d-9435-67caf821afb0	ef2e96e9-86f0-461d-9633-4d28bf075108	\N	\N
48b5d47f-22aa-40e6-8ded-6000806c87c0	509ade72-1836-461d-9435-67caf821afb0	86f85efa-d5b1-4ae8-b4d7-b06a34d6c6d8	\N	\N
31ef272c-2b42-411e-afa6-80bd70b1aa1d	509ade72-1836-461d-9435-67caf821afb0	43040892-66b1-44c1-803d-6227792a67c0	\N	\N
4c082ad2-cb3f-4dfd-88e4-99c8ba3d7dc0	509ade72-1836-461d-9435-67caf821afb0	076f0569-e95a-4939-a4fa-735638b1a488	\N	\N
1552e051-a509-4630-968a-346a86f857cf	509ade72-1836-461d-9435-67caf821afb0	c444f646-d54f-453b-80d8-140bd3383194	\N	\N
a56573c7-7b82-4866-9891-455bc1d6a13e	509ade72-1836-461d-9435-67caf821afb0	9bcc5346-bc66-439b-a7e4-910bba42ceb7	\N	\N
7a7f9a5a-332a-4dfe-bd34-1b0972bb78fa	509ade72-1836-461d-9435-67caf821afb0	31daa9f4-70f8-4585-9b97-085307be3c22	\N	\N
6cdcfdb7-df0b-4ea4-8a3d-c6cf50c6472b	00005960-5adf-4834-b188-3aa30121c5dc	f489280e-6e51-44ff-9443-f3a053c04f78	\N	\N
06079874-c545-4f78-a6da-cc2f02a6f22a	00005960-5adf-4834-b188-3aa30121c5dc	4ae2893a-9d81-42f4-b470-85e637039109	\N	\N
b5800316-cabb-4553-975a-89acb0232842	00005960-5adf-4834-b188-3aa30121c5dc	0cdde8a9-1253-40f5-b473-c340ceaf813a	\N	\N
a5c383bb-3e5d-4e07-97d5-03b423916145	00005960-5adf-4834-b188-3aa30121c5dc	33532ab4-0af2-4a15-b7aa-75b2cc21e0e1	\N	\N
fb6b5b1b-4bd0-4853-bb9d-fd4a3a4315a3	00005960-5adf-4834-b188-3aa30121c5dc	912e801e-17cf-4df5-833e-71244bd4ed4e	\N	\N
f2371ae8-5798-437d-983e-185f20fda90e	00005960-5adf-4834-b188-3aa30121c5dc	9d67a0ad-7f8b-4322-8644-cedde62b10ff	\N	\N
f6e4e37b-1b09-4331-b93b-00a53113720a	00005960-5adf-4834-b188-3aa30121c5dc	de157b04-1896-4ddc-b0dd-dc2dd7e3db46	\N	\N
60a73c58-82f2-4906-8ffb-a83cf3b7fcf9	00005960-5adf-4834-b188-3aa30121c5dc	2d0bfeef-2b8a-481c-a13b-5674fe4a024d	\N	\N
ade34388-700f-4c70-83f8-6ebe21e8e0cd	00005960-5adf-4834-b188-3aa30121c5dc	9645c3e9-4498-4ed9-99af-b777de16159e	\N	\N
d7cf1c82-c1b7-4f21-9da6-d6b59471a454	00005960-5adf-4834-b188-3aa30121c5dc	7394e1a9-035a-4f46-9010-201cf94d543f	\N	\N
f4091360-e402-43a8-969d-50cb4b5ffbec	00005960-5adf-4834-b188-3aa30121c5dc	2a08060e-673d-4dc4-8207-705cd9f50356	\N	\N
dd95895c-efa8-4be8-b93d-fdfd558915e3	00005960-5adf-4834-b188-3aa30121c5dc	292e43d2-47d3-4f76-9f8f-72db2bb1734b	\N	\N
7d52f195-ed65-4224-8cc4-255d1ed5a03d	00005960-5adf-4834-b188-3aa30121c5dc	a3b8feb6-cdd7-4dd9-812f-d73b2d5619c5	\N	\N
802c2109-d48a-4ca1-bd97-fd8e3dab0b78	00005960-5adf-4834-b188-3aa30121c5dc	f31dacb5-9bee-4c38-b9d8-9e2e9d68c8f6	\N	\N
a26a7da2-0504-40d2-8a78-a6468b61b6d7	00005960-5adf-4834-b188-3aa30121c5dc	ea64bb52-2fd3-420b-96e0-168854abc3d3	\N	\N
d93cc989-9018-4a24-8249-fd9bf32c6313	00005960-5adf-4834-b188-3aa30121c5dc	8a77ade1-b146-4ab0-b5d1-6c9993db00a8	\N	\N
73d1bbc5-db77-4fad-94ee-27bb6f8b41d6	00005960-5adf-4834-b188-3aa30121c5dc	0256e2a4-18de-4337-b7fe-0f0dcf851a61	\N	\N
e10a6896-dbcd-455e-8dce-b5c589b2b0a3	00005960-5adf-4834-b188-3aa30121c5dc	c6fd877d-6beb-47c4-b002-cddb48454774	\N	\N
5875b108-4f37-4ce2-bc68-3a89dd05234e	00005960-5adf-4834-b188-3aa30121c5dc	e7325fc0-853a-4f73-9ade-f07ad39cf1f3	\N	\N
87cc744d-09d0-4f9d-8ebb-a2ebc0d08e42	00005960-5adf-4834-b188-3aa30121c5dc	338c677b-f482-4c0a-8915-30c85079743e	\N	\N
152c9528-8365-441d-b026-c47102427a13	41da3104-ea6d-4906-a961-9d31e34fd2d1	2f06d10f-676c-4b51-ba98-13e9b1e5ec12	\N	\N
0cb63199-5535-4045-964c-695f2f4980f8	41da3104-ea6d-4906-a961-9d31e34fd2d1	34418926-9a60-49e9-a10f-c58bb0c5f14c	\N	\N
fa9d7089-81ed-48e4-982e-21ce52b5d7eb	41da3104-ea6d-4906-a961-9d31e34fd2d1	1394282a-6a8b-46d4-905b-2e4791808df9	\N	\N
7676c5ba-afc0-4e2a-b3fe-d2f85784cd86	41da3104-ea6d-4906-a961-9d31e34fd2d1	1958cc0c-e5aa-4b92-a6b3-7ef094feb395	\N	\N
a09fa18c-7f34-4814-b679-b6c3c06974cd	41da3104-ea6d-4906-a961-9d31e34fd2d1	8806afc6-151e-4a58-be1c-b6def9e51b87	\N	\N
2a7b6d0a-8742-4e3c-9ce6-10cc433cab71	41da3104-ea6d-4906-a961-9d31e34fd2d1	63cbe8d5-c743-41a5-89a5-af1a3ef3b7f5	\N	\N
5fea1829-7264-426f-8b3c-aed6781a26a5	41da3104-ea6d-4906-a961-9d31e34fd2d1	532602c4-7b0b-4c8a-93ad-b6d4ba05a8b0	\N	\N
c8f78b53-9f57-468f-a393-d4b4c46e7a72	41da3104-ea6d-4906-a961-9d31e34fd2d1	8d0cb79f-0b7f-4449-8c6e-714bd7fad5da	\N	\N
927e4b14-8a3d-4a6d-87d5-db56e2a97cc8	41da3104-ea6d-4906-a961-9d31e34fd2d1	2e44c447-3d6b-41ec-aa07-e83958bd35d5	\N	\N
54110fa3-e56b-45cf-b56c-f05123b4cd0f	41da3104-ea6d-4906-a961-9d31e34fd2d1	d466c4c5-7c3b-45a6-bf8e-1a2c56168bbf	\N	\N
952f80dd-707c-42c0-86ae-6415248307db	41da3104-ea6d-4906-a961-9d31e34fd2d1	8395e4d1-89fc-47c3-a36d-cf0a889e80ed	\N	\N
8b2a66ac-0a7d-4b75-be32-db2f74675b99	41da3104-ea6d-4906-a961-9d31e34fd2d1	d677220f-45e3-4e84-92b0-f37f02c84919	\N	\N
9b87535a-e204-410e-b0ab-6dfa1076d7f7	41da3104-ea6d-4906-a961-9d31e34fd2d1	6270c9ee-b557-4de6-9cd1-2466297d4ffc	\N	\N
8ed97a95-ad68-47f7-b01b-b0fd877aa1e9	41da3104-ea6d-4906-a961-9d31e34fd2d1	cf130d9d-cb82-4178-88f0-854e9af510b7	\N	\N
013078b9-2334-4acf-8581-fc9646e58329	41da3104-ea6d-4906-a961-9d31e34fd2d1	bee85c7e-6e9f-473a-ac52-7add2cf387ee	\N	\N
4d502588-1454-4c54-b00f-967d9f0c215b	41da3104-ea6d-4906-a961-9d31e34fd2d1	1e44053a-98c6-4b4c-817b-223dccc5b067	\N	\N
61946b40-4b56-453a-9677-91ccbb7fd078	41da3104-ea6d-4906-a961-9d31e34fd2d1	a03f98b3-5466-4c83-96dd-6018d8388fa9	\N	\N
549a9ed9-8607-4e2f-92c7-1e4a8756e3e5	41da3104-ea6d-4906-a961-9d31e34fd2d1	e96c5866-463e-430a-af22-3ad2fc8f9e36	\N	\N
be660226-7127-4954-92ec-0370d483e53a	41da3104-ea6d-4906-a961-9d31e34fd2d1	b8af0600-5463-48ac-b67f-d0d4ece23f25	\N	\N
0d41fba2-d115-427e-af48-cd9f468de3d6	41da3104-ea6d-4906-a961-9d31e34fd2d1	bccbfb2b-9dc6-469a-9742-33d889a0486d	\N	\N
eeb1d0e4-197a-4fb3-b736-15aff1dad53f	eabcf0da-f8e5-443a-8923-929365b14727	f489280e-6e51-44ff-9443-f3a053c04f78	\N	\N
b213be39-aa6d-4bef-aafb-9430946333fb	eabcf0da-f8e5-443a-8923-929365b14727	4ae2893a-9d81-42f4-b470-85e637039109	\N	\N
3df9d6ec-363c-42ec-81dd-e2dd5771e9d7	eabcf0da-f8e5-443a-8923-929365b14727	0cdde8a9-1253-40f5-b473-c340ceaf813a	\N	\N
d7028a4f-b452-4db3-ada9-a4adcd218839	eabcf0da-f8e5-443a-8923-929365b14727	33532ab4-0af2-4a15-b7aa-75b2cc21e0e1	\N	\N
c230e996-e1d7-479a-b8b5-0acbf36e2033	eabcf0da-f8e5-443a-8923-929365b14727	912e801e-17cf-4df5-833e-71244bd4ed4e	\N	\N
71c92976-d4da-40c5-845b-9e44ee8bd167	eabcf0da-f8e5-443a-8923-929365b14727	9d67a0ad-7f8b-4322-8644-cedde62b10ff	\N	\N
56f85cd7-8dfe-4cec-94c1-300587df3a09	eabcf0da-f8e5-443a-8923-929365b14727	de157b04-1896-4ddc-b0dd-dc2dd7e3db46	\N	\N
f24dc0b6-d8ea-4b01-af30-bfe762d9abf6	eabcf0da-f8e5-443a-8923-929365b14727	2d0bfeef-2b8a-481c-a13b-5674fe4a024d	\N	\N
1eac5c80-5da8-499e-aa07-4e13acb8cdb5	eabcf0da-f8e5-443a-8923-929365b14727	9645c3e9-4498-4ed9-99af-b777de16159e	\N	\N
4a193251-4137-4962-856c-42b34caa36a2	eabcf0da-f8e5-443a-8923-929365b14727	7394e1a9-035a-4f46-9010-201cf94d543f	\N	\N
896c6575-709f-4d31-b1c3-cd12886ccfac	eabcf0da-f8e5-443a-8923-929365b14727	2a08060e-673d-4dc4-8207-705cd9f50356	\N	\N
f8ca5d71-9125-4db9-abf0-9e2d29d34dcc	eabcf0da-f8e5-443a-8923-929365b14727	292e43d2-47d3-4f76-9f8f-72db2bb1734b	\N	\N
ec830d67-da6e-4e90-963b-ecd15e9562ff	eabcf0da-f8e5-443a-8923-929365b14727	a3b8feb6-cdd7-4dd9-812f-d73b2d5619c5	\N	\N
c9c19f9f-c2fb-4c7f-8baa-014f74a352e6	eabcf0da-f8e5-443a-8923-929365b14727	f31dacb5-9bee-4c38-b9d8-9e2e9d68c8f6	\N	\N
b89d030a-d991-4caa-a52a-d5048f104a43	eabcf0da-f8e5-443a-8923-929365b14727	ea64bb52-2fd3-420b-96e0-168854abc3d3	\N	\N
fa95ecf4-58b3-4965-841f-3787f6e91e63	eabcf0da-f8e5-443a-8923-929365b14727	8a77ade1-b146-4ab0-b5d1-6c9993db00a8	\N	\N
a13c43ba-318e-44f7-9818-e2d8796705a0	eabcf0da-f8e5-443a-8923-929365b14727	0256e2a4-18de-4337-b7fe-0f0dcf851a61	\N	\N
e2e8e0c6-ae7d-4bbf-8233-8d49c215f990	eabcf0da-f8e5-443a-8923-929365b14727	c6fd877d-6beb-47c4-b002-cddb48454774	\N	\N
d1e9ef2c-8934-4de8-b656-e6cd94f9905d	eabcf0da-f8e5-443a-8923-929365b14727	e7325fc0-853a-4f73-9ade-f07ad39cf1f3	\N	\N
15576c95-297e-44f5-ba2f-3824d92c1e17	eabcf0da-f8e5-443a-8923-929365b14727	338c677b-f482-4c0a-8915-30c85079743e	\N	\N
f59c27c4-4f03-4c96-b0ad-5140788533b9	eabcf0da-f8e5-443a-8923-929365b14727	2f06d10f-676c-4b51-ba98-13e9b1e5ec12	\N	\N
ba8a732a-4504-4592-bb7f-1da399c36883	eabcf0da-f8e5-443a-8923-929365b14727	34418926-9a60-49e9-a10f-c58bb0c5f14c	\N	\N
a8ecddc0-c0ed-4e69-96ac-695240a79a9f	eabcf0da-f8e5-443a-8923-929365b14727	1394282a-6a8b-46d4-905b-2e4791808df9	\N	\N
b08cb4ae-cba5-40a5-b63f-cd50cf912d4a	eabcf0da-f8e5-443a-8923-929365b14727	1958cc0c-e5aa-4b92-a6b3-7ef094feb395	\N	\N
59ec694d-381f-4f45-affc-f2c4d388934f	eabcf0da-f8e5-443a-8923-929365b14727	8806afc6-151e-4a58-be1c-b6def9e51b87	\N	\N
c50f2230-dfd5-45bf-bc5c-ed0e31ced564	eabcf0da-f8e5-443a-8923-929365b14727	63cbe8d5-c743-41a5-89a5-af1a3ef3b7f5	\N	\N
74a8eba7-c671-41f6-a38a-5fb75548c12d	eabcf0da-f8e5-443a-8923-929365b14727	532602c4-7b0b-4c8a-93ad-b6d4ba05a8b0	\N	\N
976bde30-1288-4238-a181-d609420b274f	eabcf0da-f8e5-443a-8923-929365b14727	8d0cb79f-0b7f-4449-8c6e-714bd7fad5da	\N	\N
82bccc11-983e-4367-9260-bcd9c0e073e6	eabcf0da-f8e5-443a-8923-929365b14727	2e44c447-3d6b-41ec-aa07-e83958bd35d5	\N	\N
8a6b5e48-acfb-4df2-a3bb-72982bc6b9e5	eabcf0da-f8e5-443a-8923-929365b14727	d466c4c5-7c3b-45a6-bf8e-1a2c56168bbf	\N	\N
069add20-29a5-44bf-a729-962c391b1674	eabcf0da-f8e5-443a-8923-929365b14727	8395e4d1-89fc-47c3-a36d-cf0a889e80ed	\N	\N
f79d75a9-98e4-471c-b66f-09ffd7dd839f	eabcf0da-f8e5-443a-8923-929365b14727	d677220f-45e3-4e84-92b0-f37f02c84919	\N	\N
bcac4310-5d3d-4f55-9c23-6e106ef8c933	eabcf0da-f8e5-443a-8923-929365b14727	6270c9ee-b557-4de6-9cd1-2466297d4ffc	\N	\N
3f63552a-0886-472f-a475-1e36dcc30e86	eabcf0da-f8e5-443a-8923-929365b14727	cf130d9d-cb82-4178-88f0-854e9af510b7	\N	\N
54ce88a0-1d49-46bb-a73b-064919579cd3	eabcf0da-f8e5-443a-8923-929365b14727	bee85c7e-6e9f-473a-ac52-7add2cf387ee	\N	\N
717513ff-f00f-4aae-833e-25cd37a923a8	eabcf0da-f8e5-443a-8923-929365b14727	1e44053a-98c6-4b4c-817b-223dccc5b067	\N	\N
2bd52c33-cb91-46b9-846c-549eb059653c	eabcf0da-f8e5-443a-8923-929365b14727	a03f98b3-5466-4c83-96dd-6018d8388fa9	\N	\N
05e11419-9fb8-4ddd-87dd-5fe7331d2dc2	eabcf0da-f8e5-443a-8923-929365b14727	e96c5866-463e-430a-af22-3ad2fc8f9e36	\N	\N
9457a63b-2c1b-4978-a335-45296ea16ca4	eabcf0da-f8e5-443a-8923-929365b14727	b8af0600-5463-48ac-b67f-d0d4ece23f25	\N	\N
eff1d1d6-d97a-4287-ab95-f9e8e17ad856	eabcf0da-f8e5-443a-8923-929365b14727	bccbfb2b-9dc6-469a-9742-33d889a0486d	\N	\N
89386a6c-ed08-46f1-8975-59b67fb67a86	eabcf0da-f8e5-443a-8923-929365b14727	aed87aee-d487-4558-8095-a88cc4bf9ff6	\N	\N
d6c08668-391e-4f15-a9ec-4cfab5a968da	eabcf0da-f8e5-443a-8923-929365b14727	26be8619-fd70-4e13-94b7-735568ea82d7	\N	\N
06c7e976-9169-4d10-9a93-e117e2ec3019	eabcf0da-f8e5-443a-8923-929365b14727	88be355b-b152-4071-9f9c-741c1d7d83f8	\N	\N
e616de33-5606-4886-b74d-e49fc6b62088	eabcf0da-f8e5-443a-8923-929365b14727	53f6e22a-822e-4819-9506-02ed80ca66e6	\N	\N
0001a17e-2543-4fd6-89aa-28c1a21a7d5f	eabcf0da-f8e5-443a-8923-929365b14727	a7a5fe0d-962f-46a6-9361-0db18ec11eca	\N	\N
50bef881-7f3b-42e0-a50a-5ebc30ea2604	eabcf0da-f8e5-443a-8923-929365b14727	b7909343-53d3-4c2f-bf3a-f4e2ca47d805	\N	\N
8e94c9e1-29c6-442d-8460-29859c23a6f8	509ade72-1836-461d-9435-67caf821afb0	2ab4ea00-bb6f-4631-9202-93ae2971d6e6	0	\N
3efe4949-120e-4d9a-bd58-5eeddd516181	eabcf0da-f8e5-443a-8923-929365b14727	cc8a241c-b0a3-4a7b-a632-6073a46374c7	\N	\N
0beeb304-5713-497e-b279-fdc0df82c458	eabcf0da-f8e5-443a-8923-929365b14727	3e12dc69-ea5d-4e52-bc87-6b52f5aefef9	\N	\N
4cbefab6-4ff8-4b35-8e08-7c434b1638fc	eabcf0da-f8e5-443a-8923-929365b14727	49217046-631c-4098-a232-0c225ebcaf6e	\N	\N
6cca4998-2267-491c-9ebf-947e39767339	eabcf0da-f8e5-443a-8923-929365b14727	5379ebbc-9376-4aa8-80d0-949ec2fd5ac5	\N	\N
b7200e4b-d348-4c62-8ba4-3c56edf35f98	eabcf0da-f8e5-443a-8923-929365b14727	0b1e18c5-6194-4eb3-a25a-29ef79cb06f3	\N	\N
bd6670ac-64da-4ab3-a1a1-3c556979f1dd	eabcf0da-f8e5-443a-8923-929365b14727	9abb6cdd-40e4-45b5-a00a-0d78239e29f1	\N	\N
e6aae2f4-977d-4eca-9bbd-3312bfdb8d9d	eabcf0da-f8e5-443a-8923-929365b14727	ef2e96e9-86f0-461d-9633-4d28bf075108	\N	\N
112f42df-a556-4945-8058-643dc9800b43	eabcf0da-f8e5-443a-8923-929365b14727	86f85efa-d5b1-4ae8-b4d7-b06a34d6c6d8	\N	\N
2a743f36-e5a8-4683-893e-3d9fa87ca1ec	eabcf0da-f8e5-443a-8923-929365b14727	43040892-66b1-44c1-803d-6227792a67c0	\N	\N
38b8e761-e189-4d67-b5b5-3b331bd4d2c3	eabcf0da-f8e5-443a-8923-929365b14727	076f0569-e95a-4939-a4fa-735638b1a488	\N	\N
7092b69e-ad84-43a5-9940-0a57b6f75c09	eabcf0da-f8e5-443a-8923-929365b14727	c444f646-d54f-453b-80d8-140bd3383194	\N	\N
594bb65a-bd29-4234-b89c-e98fdd407e6e	eabcf0da-f8e5-443a-8923-929365b14727	9bcc5346-bc66-439b-a7e4-910bba42ceb7	\N	\N
7aeec723-fa7e-4e69-8be4-9b349420ec74	eabcf0da-f8e5-443a-8923-929365b14727	31daa9f4-70f8-4585-9b97-085307be3c22	\N	\N
04b7cd5c-7a94-4d25-a28a-66885e35338e	371e992d-42d2-4393-b08e-d36e3ff49db5	f489280e-6e51-44ff-9443-f3a053c04f78	\N	\N
54f55952-30a9-4405-8f1d-de595d7ba618	371e992d-42d2-4393-b08e-d36e3ff49db5	4ae2893a-9d81-42f4-b470-85e637039109	\N	\N
fa802704-f2a6-4b78-84c8-58e8792c2106	371e992d-42d2-4393-b08e-d36e3ff49db5	0cdde8a9-1253-40f5-b473-c340ceaf813a	\N	\N
3db24238-c123-4db0-81ca-fe52936c28fb	371e992d-42d2-4393-b08e-d36e3ff49db5	33532ab4-0af2-4a15-b7aa-75b2cc21e0e1	\N	\N
9d59abe7-c7f4-4a3e-b66f-cd5fd8265729	371e992d-42d2-4393-b08e-d36e3ff49db5	912e801e-17cf-4df5-833e-71244bd4ed4e	\N	\N
26d9c4e2-c9ea-4fb5-8258-95e43404ee8c	371e992d-42d2-4393-b08e-d36e3ff49db5	9d67a0ad-7f8b-4322-8644-cedde62b10ff	\N	\N
3ab8a63f-bc2b-4135-9f14-b975154771c0	371e992d-42d2-4393-b08e-d36e3ff49db5	de157b04-1896-4ddc-b0dd-dc2dd7e3db46	\N	\N
c37aa003-aa3e-40fe-acca-f8d287936838	371e992d-42d2-4393-b08e-d36e3ff49db5	2d0bfeef-2b8a-481c-a13b-5674fe4a024d	\N	\N
ac513c8c-8437-4cf3-8fb6-0a13b936299f	371e992d-42d2-4393-b08e-d36e3ff49db5	9645c3e9-4498-4ed9-99af-b777de16159e	\N	\N
efcae24b-3ca2-4ac5-a8bc-ce635ed92637	371e992d-42d2-4393-b08e-d36e3ff49db5	7394e1a9-035a-4f46-9010-201cf94d543f	\N	\N
ae09bcf7-5d8c-4e30-9713-a15df630581d	371e992d-42d2-4393-b08e-d36e3ff49db5	2a08060e-673d-4dc4-8207-705cd9f50356	\N	\N
688fd6ca-d56f-46d7-a4e0-3bed3efb5abb	371e992d-42d2-4393-b08e-d36e3ff49db5	292e43d2-47d3-4f76-9f8f-72db2bb1734b	\N	\N
0746cb03-041a-478b-a5e8-462253d0e9e9	371e992d-42d2-4393-b08e-d36e3ff49db5	a3b8feb6-cdd7-4dd9-812f-d73b2d5619c5	\N	\N
237ea309-5f20-4ad9-bc60-eff8f750f28d	371e992d-42d2-4393-b08e-d36e3ff49db5	f31dacb5-9bee-4c38-b9d8-9e2e9d68c8f6	\N	\N
66623515-4ec1-4b2f-9b23-2ae065832fdb	371e992d-42d2-4393-b08e-d36e3ff49db5	ea64bb52-2fd3-420b-96e0-168854abc3d3	\N	\N
2bd2027c-2056-48f3-ad62-ab1083d047cc	371e992d-42d2-4393-b08e-d36e3ff49db5	8a77ade1-b146-4ab0-b5d1-6c9993db00a8	\N	\N
98721441-5380-4ec5-8d4a-245ca9f58f3d	371e992d-42d2-4393-b08e-d36e3ff49db5	0256e2a4-18de-4337-b7fe-0f0dcf851a61	\N	\N
dd16ccb7-bf37-4bf6-b429-68910ab40293	371e992d-42d2-4393-b08e-d36e3ff49db5	c6fd877d-6beb-47c4-b002-cddb48454774	\N	\N
c7e0cc34-0707-4506-ac4a-0d657e4670a2	371e992d-42d2-4393-b08e-d36e3ff49db5	e7325fc0-853a-4f73-9ade-f07ad39cf1f3	\N	\N
9b2a4fe4-9222-44ad-9e03-f8f66e066ac5	371e992d-42d2-4393-b08e-d36e3ff49db5	338c677b-f482-4c0a-8915-30c85079743e	\N	\N
139a9fd9-29da-474b-9754-bfbfa666cf09	371e992d-42d2-4393-b08e-d36e3ff49db5	2f06d10f-676c-4b51-ba98-13e9b1e5ec12	\N	\N
6742c27d-0f7b-436e-b803-409b6c4b73ad	371e992d-42d2-4393-b08e-d36e3ff49db5	34418926-9a60-49e9-a10f-c58bb0c5f14c	\N	\N
3bc2c882-4c52-4d7d-a3da-532a1d243710	371e992d-42d2-4393-b08e-d36e3ff49db5	1394282a-6a8b-46d4-905b-2e4791808df9	\N	\N
3e1f6a10-7331-40ca-9b8f-967ea791bfcc	371e992d-42d2-4393-b08e-d36e3ff49db5	1958cc0c-e5aa-4b92-a6b3-7ef094feb395	\N	\N
40d48761-9cbe-4260-bc3a-a0d0b7036492	371e992d-42d2-4393-b08e-d36e3ff49db5	8806afc6-151e-4a58-be1c-b6def9e51b87	\N	\N
0192c01a-a400-4b99-97b3-361bfd09054c	371e992d-42d2-4393-b08e-d36e3ff49db5	63cbe8d5-c743-41a5-89a5-af1a3ef3b7f5	\N	\N
8835cb4d-7658-4a3a-9c8d-63202c5aaf60	371e992d-42d2-4393-b08e-d36e3ff49db5	532602c4-7b0b-4c8a-93ad-b6d4ba05a8b0	\N	\N
0c8918d2-3382-46bc-8d81-3bf0e2bc3e0c	371e992d-42d2-4393-b08e-d36e3ff49db5	8d0cb79f-0b7f-4449-8c6e-714bd7fad5da	\N	\N
547f366f-0329-4813-a11f-87835fd84dd1	371e992d-42d2-4393-b08e-d36e3ff49db5	2e44c447-3d6b-41ec-aa07-e83958bd35d5	\N	\N
f47cd920-9728-4786-9243-e29000bdbefc	371e992d-42d2-4393-b08e-d36e3ff49db5	d466c4c5-7c3b-45a6-bf8e-1a2c56168bbf	\N	\N
78a12303-2c55-4ea8-a6b9-71df10a2f796	371e992d-42d2-4393-b08e-d36e3ff49db5	8395e4d1-89fc-47c3-a36d-cf0a889e80ed	\N	\N
89a36ce5-c71a-46fb-b5f7-d2f9208ba5c1	371e992d-42d2-4393-b08e-d36e3ff49db5	d677220f-45e3-4e84-92b0-f37f02c84919	\N	\N
53c68c6b-44fb-41d3-be77-53f6500be993	371e992d-42d2-4393-b08e-d36e3ff49db5	6270c9ee-b557-4de6-9cd1-2466297d4ffc	\N	\N
28b1ffd2-ddbe-4c7a-b590-cc9421db0a72	371e992d-42d2-4393-b08e-d36e3ff49db5	cf130d9d-cb82-4178-88f0-854e9af510b7	\N	\N
4129230f-1f05-454f-a95f-07fe69ce917d	371e992d-42d2-4393-b08e-d36e3ff49db5	bee85c7e-6e9f-473a-ac52-7add2cf387ee	\N	\N
6ab125f1-1548-4e1f-a03d-93b2df641afa	371e992d-42d2-4393-b08e-d36e3ff49db5	1e44053a-98c6-4b4c-817b-223dccc5b067	\N	\N
f56bd69c-fe69-4771-9fb4-3a01960c001e	371e992d-42d2-4393-b08e-d36e3ff49db5	a03f98b3-5466-4c83-96dd-6018d8388fa9	\N	\N
bcbc4a8c-ba93-4de8-893c-412f81d43066	371e992d-42d2-4393-b08e-d36e3ff49db5	e96c5866-463e-430a-af22-3ad2fc8f9e36	\N	\N
f0bc9c8b-7107-468d-bb03-9bd8521c5fef	371e992d-42d2-4393-b08e-d36e3ff49db5	b8af0600-5463-48ac-b67f-d0d4ece23f25	\N	\N
062e330d-23e1-4bf1-bdb1-eda3aac5b2f7	371e992d-42d2-4393-b08e-d36e3ff49db5	bccbfb2b-9dc6-469a-9742-33d889a0486d	\N	\N
4d4cc842-da74-4ec5-ac62-8db5e33165b2	371e992d-42d2-4393-b08e-d36e3ff49db5	2ab4ea00-bb6f-4631-9202-93ae2971d6e6	\N	\N
e321c819-5942-48a6-976a-3f5730d29aba	371e992d-42d2-4393-b08e-d36e3ff49db5	aed87aee-d487-4558-8095-a88cc4bf9ff6	\N	\N
1c454c83-3399-47fa-810d-60d1ce26a95b	371e992d-42d2-4393-b08e-d36e3ff49db5	26be8619-fd70-4e13-94b7-735568ea82d7	\N	\N
b5dfb4e8-4545-4968-ba35-26b9f6c6292a	371e992d-42d2-4393-b08e-d36e3ff49db5	88be355b-b152-4071-9f9c-741c1d7d83f8	\N	\N
a1551e5c-3aae-42b0-8579-7dfb4a60d49d	371e992d-42d2-4393-b08e-d36e3ff49db5	53f6e22a-822e-4819-9506-02ed80ca66e6	\N	\N
4182513a-c4b1-440a-ade1-6534048b9126	371e992d-42d2-4393-b08e-d36e3ff49db5	a7a5fe0d-962f-46a6-9361-0db18ec11eca	\N	\N
a52557bc-9eca-419b-a830-bd8cca6d6f86	371e992d-42d2-4393-b08e-d36e3ff49db5	b7909343-53d3-4c2f-bf3a-f4e2ca47d805	\N	\N
2cac0556-ec3b-464e-a2b9-bfd8abf66d54	371e992d-42d2-4393-b08e-d36e3ff49db5	cc8a241c-b0a3-4a7b-a632-6073a46374c7	\N	\N
21f77e5a-9bab-445b-9354-16b770af8425	371e992d-42d2-4393-b08e-d36e3ff49db5	3e12dc69-ea5d-4e52-bc87-6b52f5aefef9	\N	\N
b4cfa613-1a2c-4471-aa49-ad8ae28bce62	371e992d-42d2-4393-b08e-d36e3ff49db5	49217046-631c-4098-a232-0c225ebcaf6e	\N	\N
cb5a8107-4c0b-49fe-bef7-408c9b0cce42	371e992d-42d2-4393-b08e-d36e3ff49db5	5379ebbc-9376-4aa8-80d0-949ec2fd5ac5	\N	\N
bd6fdf51-a250-4287-aafe-70ce75aa9c22	371e992d-42d2-4393-b08e-d36e3ff49db5	0b1e18c5-6194-4eb3-a25a-29ef79cb06f3	\N	\N
d856d5e2-59fd-4d94-b99e-bf2eed155d89	371e992d-42d2-4393-b08e-d36e3ff49db5	9abb6cdd-40e4-45b5-a00a-0d78239e29f1	\N	\N
be8d8748-d021-471d-90f2-35afad62b6fd	371e992d-42d2-4393-b08e-d36e3ff49db5	ef2e96e9-86f0-461d-9633-4d28bf075108	\N	\N
26196235-a565-490d-bdb3-5eefb3668e39	371e992d-42d2-4393-b08e-d36e3ff49db5	86f85efa-d5b1-4ae8-b4d7-b06a34d6c6d8	\N	\N
cda4e780-9c03-47a0-967c-9b40e20334ac	371e992d-42d2-4393-b08e-d36e3ff49db5	43040892-66b1-44c1-803d-6227792a67c0	\N	\N
7e43ed8a-2d62-4759-a0e3-ee216af2da7e	371e992d-42d2-4393-b08e-d36e3ff49db5	076f0569-e95a-4939-a4fa-735638b1a488	\N	\N
f2b28897-8c4e-4ce5-82bd-dd2eaa8d4821	371e992d-42d2-4393-b08e-d36e3ff49db5	c444f646-d54f-453b-80d8-140bd3383194	\N	\N
a35bc90e-f865-49e6-ae40-0fc9e3c2d19c	371e992d-42d2-4393-b08e-d36e3ff49db5	9bcc5346-bc66-439b-a7e4-910bba42ceb7	\N	\N
a4f047c0-080c-43f2-b5e4-15721e1845b6	371e992d-42d2-4393-b08e-d36e3ff49db5	31daa9f4-70f8-4585-9b97-085307be3c22	\N	\N
95d7bafd-1c81-4a77-990c-a8b252a3e587	8f347975-0f73-4414-b7a8-b555158b5333	f489280e-6e51-44ff-9443-f3a053c04f78	\N	\N
8d5f516b-1190-4c00-9969-fca6349b6260	8f347975-0f73-4414-b7a8-b555158b5333	4ae2893a-9d81-42f4-b470-85e637039109	\N	\N
3b1a10b3-ba95-40f1-8a8e-4c6f79008de0	8f347975-0f73-4414-b7a8-b555158b5333	0cdde8a9-1253-40f5-b473-c340ceaf813a	\N	\N
34a93060-571f-46c6-88cd-47193b5b7703	8f347975-0f73-4414-b7a8-b555158b5333	33532ab4-0af2-4a15-b7aa-75b2cc21e0e1	\N	\N
1634dff3-ed3c-4bf3-b211-95b6ab5ca767	8f347975-0f73-4414-b7a8-b555158b5333	912e801e-17cf-4df5-833e-71244bd4ed4e	\N	\N
1dfac028-fbb8-4860-9914-5a45a155238a	8f347975-0f73-4414-b7a8-b555158b5333	9d67a0ad-7f8b-4322-8644-cedde62b10ff	\N	\N
2b7a7ece-05ff-473d-9212-cc7ff70ba78c	8f347975-0f73-4414-b7a8-b555158b5333	de157b04-1896-4ddc-b0dd-dc2dd7e3db46	\N	\N
daebc741-cf27-4a97-8dbd-d4b13c0e981b	8f347975-0f73-4414-b7a8-b555158b5333	2d0bfeef-2b8a-481c-a13b-5674fe4a024d	\N	\N
ff986998-6db8-4728-b449-a17aacf9457c	8f347975-0f73-4414-b7a8-b555158b5333	9645c3e9-4498-4ed9-99af-b777de16159e	\N	\N
52d41870-059d-4479-92e4-65fe74d6be76	8f347975-0f73-4414-b7a8-b555158b5333	7394e1a9-035a-4f46-9010-201cf94d543f	\N	\N
f0629116-c2f7-4f69-a4dd-ff308a844226	8f347975-0f73-4414-b7a8-b555158b5333	2a08060e-673d-4dc4-8207-705cd9f50356	\N	\N
8c36459e-86b1-4ea0-84fb-132690f0f86b	8f347975-0f73-4414-b7a8-b555158b5333	292e43d2-47d3-4f76-9f8f-72db2bb1734b	\N	\N
2858b269-24e1-44a7-94c9-e4818c3f539f	8f347975-0f73-4414-b7a8-b555158b5333	a3b8feb6-cdd7-4dd9-812f-d73b2d5619c5	\N	\N
86bd714b-e00f-44d7-a957-6a606762b437	8f347975-0f73-4414-b7a8-b555158b5333	f31dacb5-9bee-4c38-b9d8-9e2e9d68c8f6	\N	\N
2ba1f18c-dc75-41ea-b05f-68209079f429	8f347975-0f73-4414-b7a8-b555158b5333	ea64bb52-2fd3-420b-96e0-168854abc3d3	\N	\N
4ffd9cad-71aa-4b2a-abf6-92870bc1765d	8f347975-0f73-4414-b7a8-b555158b5333	8a77ade1-b146-4ab0-b5d1-6c9993db00a8	\N	\N
2aaa061b-ec6b-4285-8d6e-6460950df88b	8f347975-0f73-4414-b7a8-b555158b5333	0256e2a4-18de-4337-b7fe-0f0dcf851a61	\N	\N
393c8b13-4b95-49be-9978-f3270c284dc2	8f347975-0f73-4414-b7a8-b555158b5333	c6fd877d-6beb-47c4-b002-cddb48454774	\N	\N
2143a85b-81f1-4ea3-a5b5-d363fad08262	8f347975-0f73-4414-b7a8-b555158b5333	e7325fc0-853a-4f73-9ade-f07ad39cf1f3	\N	\N
04b93f81-6c1c-455e-8a3f-a104f0e7821a	8f347975-0f73-4414-b7a8-b555158b5333	338c677b-f482-4c0a-8915-30c85079743e	\N	\N
29159ad8-d6f6-49e7-a8d4-3b67af44825e	eabcf0da-f8e5-443a-8923-929365b14727	2ab4ea00-bb6f-4631-9202-93ae2971d6e6	2	\N
\.


--
-- Data for Name: labs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.labs (id, lecturer_id, subject_id, title, description, created) FROM stdin;
509ade72-1836-461d-9435-67caf821afb0	101008b8-9641-4428-bcd0-367434f16591	69b57d20-3c1e-4142-9b1c-397afe5a14c8	Лабораторная работа №1	Описание для лабораторной работы:\r\n1. ...\r\n2. ...\r\n3. ...	2025-05-28 12:03:42.642522
00005960-5adf-4834-b188-3aa30121c5dc	101008b8-9641-4428-bcd0-367434f16591	69b57d20-3c1e-4142-9b1c-397afe5a14c8	Лабораторная работа №1	Описание для лабораторной работы:\r\n1. ...\r\n2. ...\r\n3. ...	2025-05-28 12:03:53.49173
41da3104-ea6d-4906-a961-9d31e34fd2d1	101008b8-9641-4428-bcd0-367434f16591	69b57d20-3c1e-4142-9b1c-397afe5a14c8	Лабораторная работа №1	Описание для лабораторной работы:\r\n1. ...\r\n2. ...\r\n3. ...	2025-05-28 12:04:05.410275
eabcf0da-f8e5-443a-8923-929365b14727	101008b8-9641-4428-bcd0-367434f16591	69b57d20-3c1e-4142-9b1c-397afe5a14c8	Лабораторная работа №2	Описание для лабораторной работы:\r\n1. ...\r\n2. ...\r\n3. ...	2025-05-28 12:04:15.589409
8f347975-0f73-4414-b7a8-b555158b5333	101008b8-9641-4428-bcd0-367434f16591	e1e08ff8-32eb-4095-ae65-b4f0071eb62f	Лабораторная работа №1	Описание для лабораторной работы:\r\n1. ...\r\n2. ...\r\n3. ...	2025-05-28 12:04:49.051325
371e992d-42d2-4393-b08e-d36e3ff49db5	101008b8-9641-4428-bcd0-367434f16591	7bba641f-309b-41f8-91d1-7b659adc8db6	Лабораторная работа №1	Описание для лабораторной работы:\r\n1. ...\r\n2. ...\r\n3. ...	2025-05-28 12:04:29.998571
\.


--
-- Data for Name: lecturer_groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.lecturer_groups (lecturer_id, group_id) FROM stdin;
101008b8-9641-4428-bcd0-367434f16591	bb8bd1de-f50e-49b0-b984-c2e7066e0436
101008b8-9641-4428-bcd0-367434f16591	b99c24f9-8141-400c-8c38-cdb37d3daf5c
101008b8-9641-4428-bcd0-367434f16591	b28abc04-b83c-4522-97b3-b2c474c0ae08
\.


--
-- Data for Name: lecturer_subjects; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.lecturer_subjects (lecturer_id, subject_id) FROM stdin;
101008b8-9641-4428-bcd0-367434f16591	69b57d20-3c1e-4142-9b1c-397afe5a14c8
101008b8-9641-4428-bcd0-367434f16591	7bba641f-309b-41f8-91d1-7b659adc8db6
101008b8-9641-4428-bcd0-367434f16591	72e828c2-95e3-40e1-9605-8f6cc58c3ff2
101008b8-9641-4428-bcd0-367434f16591	e1e08ff8-32eb-4095-ae65-b4f0071eb62f
101008b8-9641-4428-bcd0-367434f16591	707b7162-9b81-488a-9cbf-da9720259f4f
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
e1e08ff8-32eb-4095-ae65-b4f0071eb62f	Проектирование web-приложений
7bba641f-309b-41f8-91d1-7b659adc8db6	Модели и методы искусственного интеллекта
707b7162-9b81-488a-9cbf-da9720259f4f	Тестирование программного обеспечения
69b57d20-3c1e-4142-9b1c-397afe5a14c8	Аппаратная реализация алгоритмов
72e828c2-95e3-40e1-9605-8f6cc58c3ff2	Моделирование
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

