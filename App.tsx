import React,{useEffect,useState} from 'react';
import {SafeAreaView,View,Text,TextInput,Button,FlatList,StyleSheet} from 'react-native';
import {createClient} from '@supabase/supabase-js';
import {SUPABASE_URL,SUPABASE_ANON_KEY} from './src/config';
const db=createClient(SUPABASE_URL,SUPABASE_ANON_KEY);
export default function App(){
 const [session,setSession]=useState<any>(null),[email,setEmail]=useState(''),[password,setPassword]=useState(''),[body,setBody]=useState(''),[posts,setPosts]=useState<any[]>([]),[msg,setMsg]=useState('');
 async function load(){const {data,error}=await db.from('posts').select('id,body,created_at').order('created_at',{ascending:false}).limit(50);if(error)setMsg(error.message);setPosts(data||[])}
 useEffect(()=>{db.auth.getSession().then(({data})=>setSession(data.session));const {data:{subscription}}=db.auth.onAuthStateChange((_e,s)=>setSession(s));return()=>subscription.unsubscribe()},[]);
 useEffect(()=>{if(session)load()},[session]);
 async function post(){const {error}=await db.from('posts').insert({author_id:session.user.id,body});setMsg(error?.message||'Posted');setBody('');load()}
 return <SafeAreaView style={s.page}><Text style={s.brand}>🌍 Global Community</Text>{!session?<View><TextInput style={s.input} placeholder="Email" value={email} onChangeText={setEmail}/><TextInput style={s.input} placeholder="Password" secureTextEntry value={password} onChangeText={setPassword}/><Button title="Log in" onPress={async()=>{const {error}=await db.auth.signInWithPassword({email,password});setMsg(error?.message||'')}}/><Button title="Sign up" onPress={async()=>{const {error}=await db.auth.signUp({email,password});setMsg(error?.message||'Check your email')}}/></View>:<><Text>Signed in: {session.user.email}</Text><TextInput style={s.input} placeholder="Share something..." value={body} onChangeText={setBody}/><Button title="Publish" onPress={post}/><Button title="Refresh feed" onPress={load}/><Button title="Log out" onPress={()=>db.auth.signOut()}/><FlatList data={posts} keyExtractor={x=>x.id} renderItem={({item})=><View style={s.card}><Text>{item.body}</Text><Text style={s.date}>{new Date(item.created_at).toLocaleString()}</Text></View>}/></>}{!!msg&&<Text>{msg}</Text>}</SafeAreaView>
}
const s=StyleSheet.create({page:{flex:1,backgroundColor:'#f0f2f5',padding:18},brand:{fontSize:24,fontWeight:'bold',color:'#1877f2',marginBottom:20},input:{backgroundColor:'white',padding:12,borderRadius:9,marginVertical:8},card:{backgroundColor:'white',padding:16,borderRadius:10,marginVertical:7},date:{color:'#777',fontSize:11,marginTop:8}});
