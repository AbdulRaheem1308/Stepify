import { useEffect, useState } from 'react';
import { ArrowRight, Activity, Trophy, Building2, Shield, ChevronRight, Coins, Gift, Zap, Users } from 'lucide-react';
import './index.css';

// --- Components ---

const Navbar = () => {
  const [scrolled, setScrolled] = useState(false);

  useEffect(() => {
    const handleScroll = () => {
      setScrolled(window.scrollY > 50);
    };
    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  return (
    <nav style={{
      position: 'fixed',
      top: 0,
      left: 0,
      right: 0,
      zIndex: 100,
      padding: '1.25rem 0',
      transition: 'all 0.3s ease',
      background: scrolled ? 'rgba(10, 10, 12, 0.85)' : 'transparent',
      backdropFilter: scrolled ? 'blur(16px)' : 'none',
      borderBottom: scrolled ? '1px solid var(--border-light)' : 'none'
    }}>
      <div className="container" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
          <div style={{ background: 'var(--accent-gradient)', padding: '0.5rem', borderRadius: '12px', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <Activity color="#0a0a0c" size={24} strokeWidth={2.5} />
          </div>
          <span style={{ fontFamily: 'var(--font-heading)', fontSize: '1.5rem', fontWeight: 800, letterSpacing: '-0.02em' }}>
            Wellnex
          </span>
        </div>
        <div style={{ display: 'flex', gap: '2rem', alignItems: 'center' }}>
          <a href="#how-it-works" className="nav-link">How it Works</a>
          <a href="#features" className="nav-link">Features</a>
          <a href="#corporate" className="nav-link">For Teams</a>
          <button className="btn btn-primary" style={{ padding: '0.6rem 1.5rem', fontSize: '0.9rem' }}>
            Download App
          </button>
        </div>
      </div>
    </nav>
  );
};

const Hero = () => {
  return (
    <section className="section" style={{ minHeight: '100vh', display: 'flex', alignItems: 'center', paddingTop: '8rem', position: 'relative', overflow: 'hidden' }}>
      {/* Dynamic Background Elements */}
      <div style={{ position: 'absolute', top: '10%', left: '40%', transform: 'translate(-50%, -50%)', width: '80vw', height: '80vw', background: 'radial-gradient(circle, rgba(0, 255, 136, 0.08) 0%, rgba(0,0,0,0) 60%)', filter: 'blur(80px)', zIndex: -1 }}></div>
      <div style={{ position: 'absolute', bottom: '-20%', right: '-10%', width: '50vw', height: '50vw', background: 'radial-gradient(circle, rgba(0, 204, 255, 0.1) 0%, rgba(0,0,0,0) 60%)', filter: 'blur(80px)', zIndex: -1 }}></div>

      <div className="container" style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', textAlign: 'center', gap: '2rem', position: 'relative', zIndex: 1 }}>
        <div className="animate-fade-up badge-pill">
          <span className="pulse-dot"></span>
          Trusted by over 10,000+ active walkers in India
        </div>
        
        <h1 className="animate-fade-up" style={{ fontSize: 'clamp(3.5rem, 7vw, 6.5rem)', maxWidth: '1000px', margin: '0 auto', animationDelay: '0.1s', lineHeight: 1.1 }}>
          Your Steps Are <br />
          <span className="text-gradient">Worth More.</span>
        </h1>
        
        <p className="animate-fade-up" style={{ fontSize: '1.25rem', color: 'var(--text-secondary)', maxWidth: '650px', margin: '0 auto', animationDelay: '0.2s' }}>
          Wellnex is the ultimate fitness app that pays you to stay healthy. Walk daily, maintain your streaks, crush challenges, and redeem exclusive rewards.
        </p>
        
        <div className="animate-fade-up" style={{ display: 'flex', gap: '1rem', marginTop: '1.5rem', animationDelay: '0.3s', flexWrap: 'wrap', justifyContent: 'center' }}>
          <button className="btn btn-primary" style={{ padding: '1.25rem 2.5rem', fontSize: '1.125rem' }}>
            Get Started Free <ArrowRight size={20} />
          </button>
          <button className="btn btn-secondary" style={{ padding: '1.25rem 2.5rem', fontSize: '1.125rem' }}>
            Explore Rewards
          </button>
        </div>
      </div>
    </section>
  );
};

const HowItWorks = () => {
  return (
    <section id="how-it-works" className="section" style={{ borderTop: '1px solid var(--border-light)' }}>
      <div className="container">
        <div style={{ textAlign: 'center', marginBottom: '5rem' }}>
          <h2 style={{ fontSize: '3rem', marginBottom: '1rem' }}>How Wellnex Works</h2>
          <p style={{ fontSize: '1.125rem', color: 'var(--text-secondary)' }}>Three simple steps to a healthier, wealthier you.</p>
        </div>

        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(280px, 1fr))', gap: '2rem', position: 'relative' }}>
          {/* Connecting Line */}
          <div className="desktop-only" style={{ position: 'absolute', top: '40px', left: '15%', right: '15%', height: '2px', background: 'var(--border-light)', zIndex: 0 }}></div>

          {[
            { icon: Activity, title: "1. Walk & Track", desc: "Our smart background tracker counts your steps automatically without draining your battery." },
            { icon: Coins, title: "2. Earn Step Coins", desc: "Every step counts. Hit your daily goals and maintain streaks to multiply your earnings." },
            { icon: Gift, title: "3. Claim Rewards", desc: "Redeem your Step Coins for exclusive discounts, brand vouchers, and premium offers." }
          ].map((step, index) => (
             <div key={index} className="glass-card text-center relative z-10" style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', padding: '3rem 2rem' }}>
                <div style={{ width: '80px', height: '80px', borderRadius: '50%', background: 'var(--bg-primary)', border: '2px solid var(--accent-primary)', display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: '1.5rem', boxShadow: 'var(--shadow-glow)' }}>
                  <step.icon color="var(--accent-primary)" size={32} />
                </div>
                <h3 style={{ fontSize: '1.5rem', marginBottom: '1rem' }}>{step.title}</h3>
                <p style={{ color: 'var(--text-secondary)' }}>{step.desc}</p>
             </div>
          ))}
        </div>
      </div>
    </section>
  );
};

const FeatureCard = ({ icon: Icon, title, description }: { icon: any, title: string, description: string }) => (
  <div className="glass-card hover-glow" style={{ display: 'flex', gap: '1.5rem', alignItems: 'flex-start' }}>
    <div style={{ width: '56px', height: '56px', borderRadius: '16px', background: 'rgba(0, 255, 136, 0.1)', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
      <Icon color="var(--accent-primary)" size={28} />
    </div>
    <div>
      <h3 style={{ fontSize: '1.25rem', marginBottom: '0.5rem' }}>{title}</h3>
      <p style={{ color: 'var(--text-secondary)', lineHeight: 1.6 }}>{description}</p>
    </div>
  </div>
);

const Features = () => {
  return (
    <section id="features" className="section" style={{ background: 'var(--bg-secondary)', position: 'relative' }}>
      <div className="container">
        <div style={{ display: 'flex', flexDirection: 'row', flexWrap: 'wrap', gap: '4rem', alignItems: 'center' }}>
          
          <div style={{ flex: '1 1 500px' }}>
            <h2 style={{ fontSize: '3.5rem', marginBottom: '1.5rem', lineHeight: 1.1 }}>More Than Just a Pedometer</h2>
            <p style={{ fontSize: '1.125rem', color: 'var(--text-secondary)', marginBottom: '3rem' }}>
              We combine accurate activity tracking with gamification psychology to ensure you build habits that last.
            </p>
            
            <div style={{ display: 'flex', flexDirection: 'column', gap: '1.5rem' }}>
              <FeatureCard 
                icon={Trophy}
                title="Gamified Streaks & Challenges"
                description="Maintain daily streaks to multiply rewards. Join global walking challenges to compete and win big."
              />
              <FeatureCard 
                icon={Zap}
                title="Battery-Optimized Sync"
                description="Our background service syncs seamlessly with Apple Health and Google Fit without killing your phone's battery."
              />
              <FeatureCard 
                icon={Shield}
                title="Advanced Anti-Cheat"
                description="Fair play is guaranteed. Our secure algorithms prevent GPS spoofing and mock locations."
              />
            </div>
          </div>

          <div style={{ flex: '1 1 400px', display: 'flex', justifyContent: 'center' }}>
             {/* Feature Visual Placeholder */}
             <div style={{ width: '100%', maxWidth: '450px', aspectRatio: '9/16', background: 'linear-gradient(135deg, var(--bg-tertiary), var(--bg-primary))', borderRadius: '32px', border: '8px solid var(--bg-primary)', boxShadow: '0 30px 60px rgba(0,0,0,0.5)', position: 'relative', overflow: 'hidden' }}>
                <div style={{ position: 'absolute', top: '10%', left: '10%', right: '10%', background: 'rgba(255,255,255,0.05)', borderRadius: '16px', padding: '1rem', border: '1px solid var(--border-light)' }}>
                   <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '1rem' }}>
                      <span style={{ color: 'var(--text-secondary)' }}>Daily Goal</span>
                      <span style={{ color: 'var(--accent-primary)', fontWeight: 'bold' }}>8,432 / 10K</span>
                   </div>
                   <div style={{ width: '100%', height: '8px', background: 'var(--bg-primary)', borderRadius: '4px', overflow: 'hidden' }}>
                      <div style={{ width: '84%', height: '100%', background: 'var(--accent-gradient)' }}></div>
                   </div>
                </div>

                <div style={{ position: 'absolute', top: '35%', left: '10%', right: '10%', background: 'rgba(255,255,255,0.05)', borderRadius: '16px', padding: '1rem', border: '1px solid var(--border-light)' }}>
                   <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
                      <div style={{ padding: '0.5rem', background: 'rgba(0, 204, 255, 0.2)', borderRadius: '8px' }}><Trophy color="var(--accent-secondary)" size={24} /></div>
                      <div>
                         <div style={{ fontWeight: 'bold' }}>7 Day Streak!</div>
                         <div style={{ fontSize: '0.8rem', color: 'var(--text-secondary)' }}>+20% Bonus Coins Active</div>
                      </div>
                   </div>
                </div>
             </div>
          </div>

        </div>
      </div>
    </section>
  );
};

const Corporate = () => {
  return (
    <section id="corporate" className="section" style={{ position: 'relative' }}>
      <div className="container">
        <div className="glass-card" style={{ display: 'flex', flexDirection: 'row', flexWrap: 'wrap', gap: '4rem', alignItems: 'center', padding: '4rem', background: 'linear-gradient(145deg, rgba(26, 26, 36, 0.8), rgba(18, 18, 22, 0.9))', position: 'relative', overflow: 'hidden' }}>
          
          <div style={{ position: 'absolute', top: 0, right: 0, width: '400px', height: '400px', background: 'radial-gradient(circle, rgba(0, 204, 255, 0.15) 0%, rgba(0,0,0,0) 70%)', filter: 'blur(40px)', zIndex: 0 }}></div>

          <div style={{ flex: '1 1 400px', zIndex: 1 }}>
            <div style={{ display: 'inline-flex', alignItems: 'center', gap: '0.5rem', padding: '0.5rem 1rem', background: 'rgba(0, 204, 255, 0.1)', border: '1px solid rgba(0, 204, 255, 0.2)', borderRadius: '9999px', fontSize: '0.875rem', fontWeight: 600, color: 'var(--accent-secondary)', marginBottom: '1.5rem' }}>
              <Building2 size={16} /> Corporate Wellness Program
            </div>
            <h2 style={{ fontSize: '3rem', marginBottom: '1.5rem' }}>Transform Your Company Culture</h2>
            <p style={{ fontSize: '1.125rem', color: 'var(--text-secondary)', marginBottom: '2rem' }}>
              Bring Wellnex to your organization. Boost employee health, reduce burnout, and foster team bonding through gamified walking challenges.
            </p>
            <ul style={{ display: 'flex', flexDirection: 'column', gap: '1rem', marginBottom: '2.5rem', listStyle: 'none' }}>
              {['Private Company Leaderboards', 'Custom Reward Structures & Vouchers', 'Detailed HR Analytics & Reports', 'Inter-Department Competitions'].map((item, i) => (
                <li key={i} style={{ display: 'flex', alignItems: 'center', gap: '0.75rem', color: 'var(--text-primary)', fontWeight: 500 }}>
                  <div style={{ background: 'rgba(0, 204, 255, 0.1)', borderRadius: '50%', padding: '4px' }}>
                    <ChevronRight size={16} color="var(--accent-secondary)" />
                  </div>
                  {item}
                </li>
              ))}
            </ul>
            <button className="btn btn-secondary" style={{ borderColor: 'var(--accent-secondary)', color: 'var(--text-primary)' }}>
              Contact B2B Sales
            </button>
          </div>
          
          <div style={{ flex: '1 1 400px', display: 'flex', justifyContent: 'center', zIndex: 1 }}>
             <div style={{ width: '100%', maxWidth: '400px', aspectRatio: '1/1', background: 'var(--bg-tertiary)', borderRadius: '24px', border: '1px solid var(--border-light)', display: 'flex', flexDirection: 'column', padding: '2rem', boxShadow: '0 24px 64px rgba(0,0,0,0.4)' }}>
               <div style={{ display: 'flex', alignItems: 'center', gap: '1rem', marginBottom: '2rem' }}>
                  <Users size={32} color="var(--accent-secondary)" />
                  <h3 style={{ fontSize: '1.5rem' }}>Team Leaderboard</h3>
               </div>
               {['Engineering Team', 'Marketing Dept', 'Sales Squad'].map((team, idx) => (
                 <div key={idx} style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '1rem', background: 'rgba(255,255,255,0.03)', borderRadius: '12px', marginBottom: '0.5rem' }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
                      <span style={{ fontWeight: 'bold', color: idx === 0 ? 'var(--accent-primary)' : 'var(--text-secondary)' }}>#{idx + 1}</span>
                      <span>{team}</span>
                    </div>
                    <span style={{ fontWeight: 600 }}>{850 - (idx * 120)}k steps</span>
                 </div>
               ))}
             </div>
          </div>
        </div>
      </div>
    </section>
  );
};

const CTA = () => (
  <section className="section" style={{ textAlign: 'center', padding: '8rem 0' }}>
    <div className="container">
      <h2 style={{ fontSize: '4rem', marginBottom: '1.5rem' }}>Ready to step up?</h2>
      <p style={{ fontSize: '1.25rem', color: 'var(--text-secondary)', marginBottom: '3rem', maxWidth: '600px', margin: '0 auto 3rem' }}>
        Join thousands of users who are already turning their daily walks into incredible rewards.
      </p>
      <button className="btn btn-primary" style={{ padding: '1.25rem 3rem', fontSize: '1.25rem' }}>
        Download Wellnex Now
      </button>
    </div>
  </section>
);

const Footer = () => (
  <footer style={{ borderTop: '1px solid var(--border-light)', padding: '4rem 0 2rem', background: 'var(--bg-secondary)' }}>
    <div className="container">
      <div style={{ display: 'flex', flexDirection: 'row', flexWrap: 'wrap', gap: '4rem', justifyContent: 'space-between', marginBottom: '4rem' }}>
        <div style={{ maxWidth: '300px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', marginBottom: '1rem' }}>
            <Activity color="var(--accent-primary)" size={24} />
            <span style={{ fontFamily: 'var(--font-heading)', fontSize: '1.25rem', fontWeight: 800 }}>Wellnex</span>
          </div>
          <p style={{ color: 'var(--text-secondary)', lineHeight: 1.6 }}>Making the world healthier, one step at a time through gamification and real-world rewards.</p>
        </div>
        <div style={{ display: 'flex', gap: '4rem', flexWrap: 'wrap' }}>
          <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
            <h4 style={{ color: 'var(--text-primary)' }}>Product</h4>
            <a href="#" className="footer-link">Download App</a>
            <a href="#features" className="footer-link">Features</a>
            <a href="#how-it-works" className="footer-link">How it Works</a>
            <a href="#corporate" className="footer-link">For Teams</a>
          </div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
            <h4 style={{ color: 'var(--text-primary)' }}>Legal</h4>
            <a href="#" className="footer-link">Privacy Policy</a>
            <a href="#" className="footer-link">Terms of Service</a>
            <a href="#" className="footer-link">Contact Support</a>
          </div>
        </div>
      </div>
      <div style={{ borderTop: '1px solid var(--border-light)', paddingTop: '2rem', display: 'flex', justifyContent: 'space-between', alignItems: 'center', color: 'var(--text-muted)', fontSize: '0.875rem', flexWrap: 'wrap', gap: '1rem' }}>
        <span>© {new Date().getFullYear()} Wellnex Wellness. All rights reserved.</span>
        <span>Made with ❤️ in India</span>
      </div>
    </div>
  </footer>
);

// --- Main App ---

function App() {
  return (
    <>
      <Navbar />
      <main>
        <Hero />
        <HowItWorks />
        <Features />
        <Corporate />
        <CTA />
      </main>
      <Footer />
    </>
  );
}

export default App;
