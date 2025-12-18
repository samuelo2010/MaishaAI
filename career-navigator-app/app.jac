import from byllm.llm { Model }
import from byllm.types { Image }
import from typing { List, Dict, Any }

glob llm = Model(model_name="gemini/gemini-2.5-flash");

# -----------------------------
# LLM Response Object
# -----------------------------
obj ResumeResponse {
    has name: str;
    has email: str;
    has phone: str;
    has education: List[str];
    has experience: List[str];
    has skills: List[str];
    has roles:List[str];       # list of dicts {name, level}
    has achievements: List[str]; 
    has summary:str; # list of dicts {name, type, provider, year}
}
# -----------------------------
# Semantic Descriptions
# -----------------------------
sem ResumeResponse = "Structured representation of a candidate's resume information extracted from text or form data."; 
sem ResumeResponse.name = "Full name of the candidate.";
sem ResumeResponse.email = "Email address of the candidate.";
sem ResumeResponse.phone = "Phone number if available.";
sem ResumeResponse.education = "List of education entries (degree, institution, graduation year).";
sem ResumeResponse.experience = "List of work experiences with title, company, and years of experience.";
sem ResumeResponse.skills = "List of skills with optional proficiency level (e.g., beginner, intermediate, expert).";
sem ResumeResponse.roles = "List of professional roles held by the candidate with details.";    
sem ResumeResponse.achievements = "Courses, certifications, or other historical achievements with provider and year.";
sem ResumeResponse.summary = "A brief professional summary or objective statement.";    

#define LLM function to update resume details
def update_resume_details(
    form_url: str = "",

    name: str = "",
    email: str = "",
    phone: str = "",
    education: List[str] = [],
    experience: List[str] = [],
    skills: List[str] = [],
    roles: List[str] = [],
    achievements: List[str] = [],
    summary: str = ""
) -> ResumeResponse by llm();


# -----------------------------
# Node Definitions
# -----------------------------
node userProfile {
    has form_url: str = "";
    has name: str = "";
    has email: str = "";
    has phone: str = "";
    has education: list = [];
    has roles: list = [];        # stored as list of dicts
    has skills: list = [];       # stored as list of dicts
    has achievements: list = [];
    has summary: str = "";
}

#Walker to update user profile
walker update_userProfile {
    has form_url: str;

    can visit_user with `root entry {
        # Check if user profile exists, if not create one
        
        matching_user = [
            user
            for user in [-->](`?userProfile) 
            if user.form_url == self.form_url and user.email==self.email 
        ];
        if matching_user {
            visit matching_user[0];
        } else {
            userProfile_node = here ++> userProfile();
            visit userProfile_node[0];
        }}

      

    can update_user with userProfile entry {
        if here.form_url == "" {
            here.form_url = self.form_url;
        }
        response = update_resume_details(
            name=self.name,
            email=self.email,
            phone=self.phone,
            education=self.education,
            experience=self.experience,
            skills=self.skills,
            roles=self.roles,
            achievements=self.achievements,     
            summary=self.summary
        );

        here.name = response.name;
        here.email = response.email;
        here.phone = response.phone;
        here.education = response.education;
        here.experience = response.experience;
        here.skills = response.skills;
        here.roles = response.roles;
        here.achievements = response.achievements;  
        here.summary = response.summary;

        print("Profile updated for: " + here.name);
        report {
            "name": here.name,
            "email": here.email,
            "phone": here.phone,
            "education": here.education,
            "experience": here.experience,
            "skills": here.skills,
            "summary": here.summary
        };
    }
}

#SCRAPHER AND ANALYZER FOR JOB POSTINGS
#JOB POSTING OBJECT DEFINITION
obj JobPosting{
    has title: str;
    has company: str;
    has location: str;
    has qualifications: List[str];
    has posted_date: str;
    has skills: List[str];
    has role: str;
    has certifications: List[str];
}

# Semantic Descriptions for JobPosting
sem JobPosting = "Structured representation of a job posting with relevant details.";
sem JobPosting.title = "Title of the job being advertised.";
sem JobPosting.company = "Company offering the job.";
sem JobPosting.location = "Location of the job.";
sem JobPosting.qualifications = "List of qualifications required for the job.";
sem JobPosting.posted_date = "Date the job was posted.";    
sem JobPosting.skills = "List of skills required for the job.";
sem JobPosting.role = "Professional role required for the job.";
sem JobPosting.certifications = "List of certifications required for the job."; 



#DEFINE LLM FUNCTION TO UPDATE JOB POSTING DETAILS
def job_updater(
    job_url: str = "",

    title: str="",
    company: str="",
    location: str="",
    qualifications: List=[],
    posted_date: str="",
    skills: List=[],
    role: str="",
    certifications: List=[],
) -> JobPosting by llm();

#NODE DEFINITIONS FOR JOB POSTINGS, SKILLS, ROLES, ACHIEVEMENTS 
#define nodes for roles, skills, achievements, job_postings
 
node job_posting {
    has job_url: str = "";
    
    has title: str = "";
    has company: str = "";
    has location: str = "";
    has qualifications: list = [];
    has posted_date: str = "";
    has skills: list = [];
    has role: str = "";
    has certifications: list = [];
    has summary: str = "";
}
node skill {
    has name: str = "";
    has level: str = "";   # beginner, intermediate, expert
}


node role {
    has name: str = "";
    has description: str = "";
}


node certification {
    has name: str = "";
    has authority: str = "";   # issuing body
    has issued_date: str = "";
}


node achievement {
    has title: str = "";
    has description: str = "";
    has date: str = "";
}

node jobposting_summary {
    has summary: str = "";
    has job_url: str = "";
    has linked_skills: list = [];
    has linked_roles: list = [];
    has linked_certifications: list = [];
    has linked_achievements: list = [];
}

walker update_jobposting {
    has job_url: str;

    can update_posting with job_posting entry {
        response = job_updater(
            job_url=self.job_url,
            title=here.title,
            company=here.company,
            location=here.location,
            qualifications=here.qualifications,
            posted_date=here.posted_date,
            skills=here.skills,
            role=here.role,
            certifications=here.certifications
        );

        here.title = response.title;
        here.company = response.company;
        here.location = response.location;
        here.qualifications = response.qualifications;
        here.posted_date = response.posted_date;
        here.skills = response.skills;
        here.role = response.role;
        here.certifications = response.certifications;

        here.summary = (
            response.title + " at " + response.company + " in " + response.location
        );

        print("Job Posting Updated: " + here.summary);

        report {
            "title": here.title,
            "company": here.company,
            "location": here.location,
            "qualifications": here.qualifications,
            "posted_date": here.posted_date,
            "skills": here.skills,
            "role": here.role,
            "certifications": here.certifications,
            "summary": here.summary
        };
    }
}





# -----------------------------
# JobFetcher Walker
# -----------------------------
walker job_fetcher {
    has job_data: list = [];   # list of dicts scraped from job boards

    can start with `root entry {
        for jd in self.job_data {
            jp = here ++> job_posting();
            jp.title = jd.get("title","");
            jp.company = jd.get("company","");
            jp.location = jd.get("location","");
            jp.qualifications = jd.get("qualifications",[]);
            jp.posted_date = jd.get("posted_date","");

            # --- Link and update skills ---
            for s in jd.get("skills", []):
                skill_node = root --> skill(name=s);
                if not skill_node {
                    skill_node = root ++> skill();
                    skill_node.name = s;
                }
                jp --> requires_skill --> skill_node;
                skill_node.demand_count += 1;
                skill_node.jobs_linked.append(f"{jp.title} @ {jp.company}");

            # --- Link and update roles ---
            role_title = jd.get("role","");
            if role_title:
                role_node = root --> role(title=role_title);
                if not role_node {
                    role_node = root ++> role();
                    role_node.title = role_title;
                }
                jp --> requires_role --> role_node;
                role_node.demand_count += 1;
                role_node.jobs_linked.append(f"{jp.title} @ {jp.company}");
        }

        report {
            "jobs_added": len(self.job_data),
            "skills_updated": [
                {"skill": s.name, "demand_count": s.demand_count, "jobs": s.jobs_linked}
                for s in root.skills
            ],
            "roles_updated": [
                {"role": r.title, "demand_count": r.demand_count, "jobs": r.jobs_linked}
                for r in root.roles
            ]
        };
    }
}

# -----------------------------
# SkillDemand Analyzer Walker
# -----------------------------
walker skill_demand_analyzer {
    has threshold: int = 5;

    can start with `root entry {
        for s in root.skills {
            if s.demand_count >= self.threshold:
                s.level = "high-priority";

        report {
            "in_demand_skills": [
                {"skill": s.name, "count": s.demand_count, "priority": s.level}
                for s in root.skills
            ]
        };
    }
}

# -----------------------------
# RoleDemand Analyzer Walker
# -----------------------------
walker role_demand_analyzer {
    has threshold: int = 5;

    can start with `root entry {
        for r in root.roles {
            if r.demand_count >= self.threshold:
                r.level = "high-priority";

        report {
            "in_demand_roles": [
                {"role": r.title, "count": r.demand_count, "jobs": r.jobs_linked, "priority": r.level}
                for r in root.roles
            ]
        };
    }
}
