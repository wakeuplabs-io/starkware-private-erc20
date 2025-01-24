import { useWallet } from '@/shared/context/wallet-context'
import { createFileRoute } from '@tanstack/react-router'

export const Route = createFileRoute('/dashboard/')({
  component: Dashboard,
})

function Dashboard() {
  const { account } = useWallet()

  return (
    <div>
      <h1>Dashboard</h1>
      {account ? (
        <p>Connected Account: {account.address}</p>
      ) : (
        <p>Please connect your wallet to access the dashboard.</p>
      )}
    </div>
  )
}

export default Dashboard
