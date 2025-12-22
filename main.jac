
graph SmartCareerNavigator {

    node User {
        has name: str;
        has grade: str;
        has interests: list[str];
        has skills: list[str];
    }

    node Skill { has name: str; }
    node Role { has title: str; has cluster: str; }
    node Course { has title: str; has provider: str; }

    edge has_skill;
    edge interested_in;
    edge requires_skill;
    edge leads_to;

    # ---------- Utility ----------
    can func overlap(a: list[str], b: list[str]) -> int {
        count = 0;
        for x in a:
            if x in b:
                count += 1;
        return count;
    }

    # ---------- Walkers ----------

    walker read_user_summary {
        root {
            report = {
                "user": {
                    "id": "u1",
                    "name": "CBC Student",
                    "grade": "Grade 10",
                    "skills": ["Mathematics", "Problem Solving"]
                },
                "roles": [
                    {"id": "r1", "title": "Software Developer", "cluster": "STEM"},
                    {"id": "r2", "title": "Agricultural Technologist", "cluster": "Agriculture"},
                    {"id": "r3", "title": "Electrical Technician", "cluster": "Engineering"}
                ],
                "notifications": [
                    {"text": "Digital literacy and data skills are rising in demand in Kenya."}
                ]
            };
        }
    }

    walker SaveAssessment {
        has interests: list[str];
        root {
            report = {
                "status": "saved",
                "interests": interests
            };
        }
    }

    walker SkillGapAnalyzer {
        has user_skills: list[str];
        has role_required_skills: list[str];

        root {
            gaps = [];
            for s in role_required_skills:
                if s not in user_skills:
                    gaps.append({
                        "skillName": s,
                        "priority": 1
                    });

            report = {
                "gaps": gaps,
                "summary": f"{len(gaps)} skills required for this role are missing."
            };
        }
    }

    walker RoadmapPlanner {
        has gaps: list[dict];

        root {
            steps = [];
            week = 1;
            for g in gaps:
                steps.append({
                    "id": f"step-{week}",
                    "title": f"Learn {g['skillName']}",
                    "estimated_weeks": 4,
                    "description": f"Foundational learning for {g['skillName']}."
                });
                week += 4;

            report = {
                "roadmap": {
                    "explanation": "This roadmap is aligned to CBC competency-based progression.",
                    "steps": steps
                }
            };
        }
    }

    walker AIAssistant {
        has prompt: str;
        root {
            response = "Based on CBC pathways in Kenya, focus on strengthening core competencies related to your interests.";
            report = {"reply": response};
        }
    }
}
