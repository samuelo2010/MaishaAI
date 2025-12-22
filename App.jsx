
import React, { useEffect, useState } from "react";

const API = "/api/jac/callWalker";

async function callWalker(walker, args = {}) {
  const res = await fetch(API, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ walker, args })
  });
  return res.json();
}

export default function App() {
  const [user, setUser] = useState(null);
  const [roles, setRoles] = useState([]);
  const [gaps, setGaps] = useState([]);
  const [roadmap, setRoadmap] = useState(null);

  useEffect(() => {
    callWalker("read_user_summary").then((r) => {
      setUser(r.user);
      setRoles(r.roles);
    });
  }, []);

  async function analyze(role) {
    const required = ["Python", "Logical Thinking"];
    const res = await callWalker("SkillGapAnalyzer", {
      user_skills: user.skills,
      role_required_skills: required
    });
    setGaps(res.gaps);
  }

  async function plan() {
    const res = await callWalker("RoadmapPlanner", { gaps });
    setRoadmap(res.roadmap);
  }

  if (!user) return <div>Loading...</div>;

  return (
    <div style={{ padding: 24, fontFamily: "Arial" }}>
      <h1>Smart Career Navigator</h1>
      <p>Welcome, {user.name}</p>

      <h2>Available Career Paths</h2>
      <ul>
        {roles.map((r) => (
          <li key={r.id}>
            {r.title} ({r.cluster})
            <button onClick={() => analyze(r)}>Analyze</button>
          </li>
        ))}
      </ul>

      {gaps.length > 0 && (
        <div>
          <h3>Skill Gaps</h3>
          <ul>
            {gaps.map((g, i) => (
              <li key={i}>{g.skillName}</li>
            ))}
          </ul>
          <button onClick={plan}>Generate Roadmap</button>
        </div>
      )}

      {roadmap && (
        <div>
          <h3>Learning Roadmap</h3>
          <p>{roadmap.explanation}</p>
          <ul>
            {roadmap.steps.map((s) => (
              <li key={s.id}>{s.title} ({s.estimated_weeks} weeks)</li>
            ))}
          </ul>
        </div>
      )}
    </div>
  );
}
