import React, { useState, useEffect } from 'react';
import { useAuth } from '../hooks/useAuth';

interface Metrics {
  leads: number;
  accounts: number;
  deals: number;
  contacts: number;
}

interface Activity {
  type: string;
  name: string;
  status: string;
  createdAt: string;
}

export default function Dashboard() {
  const { user, logout, token } = useAuth();
  const [metrics, setMetrics] = useState<Metrics>({ leads: 0, accounts: 0, deals: 0, contacts: 0 });
  const [activities, setActivities] = useState<Activity[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchDashboardData();
  }, [token]);

  const fetchDashboardData = async () => {
    try {
      const response = await fetch('/api/dashboard/metrics', {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      });

      const data = await response.json();
      
      if (data.success) {
        setMetrics(data.metrics);
        setActivities(data.recentActivities || []);
      }
    } catch (error) {
      console.error('Failed to fetch dashboard data:', error);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return <div className="flex items-center justify-center h-screen">Loading dashboard...</div>;
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <nav className="bg-white shadow">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between h-16">
            <div className="flex items-center">
              <h1 className="text-xl font-semibold text-gray-900">YITRO CRM</h1>
            </div>
            <div className="flex items-center space-x-4">
              <span className="text-sm text-gray-700">Welcome, {user?.displayName}</span>
              {user?.role === 'admin' && (
                <a href="/admin" className="text-indigo-600 hover:text-indigo-900 text-sm font-medium">
                  Admin Panel
                </a>
              )}
              <button
                onClick={logout}
                className="text-gray-500 hover:text-gray-700 text-sm font-medium"
              >
                Logout
              </button>
            </div>
          </div>
        </div>
      </nav>

      <main className="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
        <div className="px-4 py-6 sm:px-0">
          <div className="mb-8">
            <h2 className="text-2xl font-bold text-gray-900 mb-6">Dashboard</h2>
            
            {/* Metrics Cards */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
              <MetricCard title="Leads" value={metrics.leads} color="bg-blue-500" />
              <MetricCard title="Accounts" value={metrics.accounts} color="bg-green-500" />
              <MetricCard title="Active Deals" value={metrics.deals} color="bg-purple-500" />
              <MetricCard title="Contacts" value={metrics.contacts} color="bg-orange-500" />
            </div>

            {/* Recent Activities */}
            <div className="bg-white shadow rounded-lg">
              <div className="px-4 py-5 sm:p-6">
                <h3 className="text-lg leading-6 font-medium text-gray-900 mb-4">
                  Recent Activities
                </h3>
                {activities.length > 0 ? (
                  <div className="space-y-3">
                    {activities.map((activity, index) => (
                      <div key={index} className="flex items-center justify-between border-b border-gray-200 pb-2">
                        <div>
                          <span className="font-medium capitalize">{activity.type}:</span> {activity.name}
                          {activity.status && <span className="text-gray-500 ml-2">({activity.status})</span>}
                        </div>
                        <span className="text-sm text-gray-500">
                          {new Date(activity.createdAt).toLocaleDateString()}
                        </span>
                      </div>
                    ))}
                  </div>
                ) : (
                  <p className="text-gray-500">No recent activities</p>
                )}
              </div>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}

function MetricCard({ title, value, color }: { title: string; value: number; color: string }) {
  return (
    <div className="bg-white overflow-hidden shadow rounded-lg">
      <div className="p-5">
        <div className="flex items-center">
          <div className="flex-shrink-0">
            <div className={`w-8 h-8 rounded-md ${color} flex items-center justify-center`}>
              <span className="text-white font-semibold text-sm">{value}</span>
            </div>
          </div>
          <div className="ml-5 w-0 flex-1">
            <dl>
              <dt className="text-sm font-medium text-gray-500 truncate">{title}</dt>
              <dd className="text-lg font-medium text-gray-900">{value}</dd>
            </dl>
          </div>
        </div>
      </div>
    </div>
  );
}