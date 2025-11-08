/**
 * Script to set up PostgreSQL database tables for ONLYOFFICE Document Server
 * Run with: node setup-database.js
 */

const fs = require('fs');
const path = require('path');
// Use pg from DocService node_modules
const { Client } = require('./DocService/node_modules/pg');

// Database configuration (matches default.json)
const dbConfig = {
  host: 'localhost',
  port: 5432,
  database: 'onlyoffice',
  user: 'onlyoffice',
  password: 'onlyoffice'
};

async function setupDatabase() {
  const client = new Client(dbConfig);
  
  try {
    console.log('Connecting to PostgreSQL database...');
    await client.connect();
    console.log('✓ Connected to database');
    
    // Read the SQL schema file
    const sqlPath = path.join(__dirname, 'schema', 'postgresql', 'createdb.sql');
    console.log(`Reading schema file: ${sqlPath}`);
    
    if (!fs.existsSync(sqlPath)) {
      throw new Error(`Schema file not found: ${sqlPath}`);
    }
    
    const sql = fs.readFileSync(sqlPath, 'utf8');
    console.log('✓ Schema file loaded');
    
    // Execute the SQL
    console.log('Creating tables...');
    await client.query(sql);
    console.log('✓ Tables created successfully');
    
    // Verify tables exist
    const result = await client.query(`
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_schema = 'public' 
      AND table_name IN ('doc_changes', 'task_result')
      ORDER BY table_name;
    `);
    
    console.log('\n✓ Database setup complete!');
    console.log('Created tables:');
    result.rows.forEach(row => {
      console.log(`  - ${row.table_name}`);
    });
    
    if (result.rows.length < 2) {
      console.warn('\n⚠ Warning: Expected 2 tables, but found', result.rows.length);
    }
    
  } catch (error) {
    console.error('\n✗ Error setting up database:');
    console.error(error.message);
    
    if (error.code === 'ECONNREFUSED') {
      console.error('\nMake sure PostgreSQL is running on localhost:5432');
    } else if (error.code === '28P01') {
      console.error('\nAuthentication failed. Check your database credentials:');
      console.error('  User:', dbConfig.user);
      console.error('  Password:', dbConfig.password);
      console.error('  Database:', dbConfig.database);
    } else if (error.code === '3D000') {
      console.error('\nDatabase "onlyoffice" does not exist.');
      console.error('Please create it first:');
      console.error('  CREATE DATABASE onlyoffice OWNER onlyoffice;');
    }
    
    process.exit(1);
  } finally {
    await client.end();
  }
}

// Run the setup
setupDatabase().catch(console.error);

